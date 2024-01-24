defmodule Prairie.Veterinary.BisonContext do
  @moduledoc """
  We'll handle a number of concerns here around bison and their veterinary records.
  """

  import Ecto.Query

  alias Prairie.Bison.Bison
  alias Prairie.Bison.Repo, as: BisonRepo
  alias Prairie.LandManagement.Prairie, as: LMPrairie
  alias Prairie.Veterinary.Appointment
  alias Prairie.Veterinary.BisonQueries

  @doc """
  A bison is due to schedule an appointment if they have no future appointment
  scheduled.

  Bison are sorted by their most recent appointment, so those without a most
  recent appointment and/or with very distant most-recent appointment will be
  listed before bison with a very recent appointment.
  """
  def needs_to_schedule() do
    right_now = now()

    # Most recent
    last_appointment_subq =
      from(
        appointment in Appointment,
        group_by: [appointment.bison_id, appointment.id],
        where: appointment.appointment_at <= ^right_now,
        order_by: [desc: appointment.appointment_at]
      )

    # Soonest upcoming
    next_appointment_subq =
      from(
        appointment in Appointment,
        group_by: [appointment.bison_id, appointment.id],
        where: appointment.appointment_at > ^right_now,
        order_by: [asc: appointment.appointment_at]
      )

    BisonRepo.all(
      from b in Bison,
        left_join: last_appointment in subquery(last_appointment_subq),
        on: last_appointment.bison_id == b.id,
        left_join: next_appointment in subquery(next_appointment_subq),
        on: next_appointment.bison_id == b.id,
        where: is_nil(next_appointment),
        order_by: [asc_nulls_first: last_appointment.appointment_at],
        select_merge: %{last_appointment_at: last_appointment.appointment_at},
        select_merge: %{next_appointment_at: next_appointment.appointment_at}
    )
  end

  @doc """
  A bison is overdue for appointment if they haven't had an appointment in the
  last 6 months. Bison need semi-annual wellness checks to ensure maximum health
  and shagginess.

  This set of methods returns the list of bison who are overdue for an
  appointment, but gives you the entire list, or the list filtered by just one
  prairie, or the list filtered by just one veterinarian.
  """
  def overdue_for_appointment() do
    Bison
    |> with_last_appointment()
    |> by_nil_last_appointment()
    |> BisonRepo.all()
  end

  def overdue_for_appointment(%LMPrairie{} = prairie) do
    Bison
    |> with_last_appointment()
    |> by_nil_last_appointment()
    |> in_prairie(prairie)
    |> BisonRepo.all()
  end

  def overdue_for_appointment(state_code) when is_binary(state_code) do
    base_query()
    |> with_last_appointment()
    |> by_nil_last_appointment()
    |> with_prairie()
    |> by_state_code(state_code)
    |> BisonRepo.all()
  end

  def base_query() do
    from bison in Bison,
      where: is_nil(bison.deleted_at),
      preload: [:appointments, :veterinarian]
  end

  def with_prairie(queryable \\ base_query()) do
    if has_named_binding?(queryable, :prairie) do
      queryable
    else
      from bison in queryable,
      join: prairie in assoc(bison, :prairie), as: :prairie
    end
  end

  def by_state_code(queryable, state_code) do
    from [bison, prairie: prairie] in queryable,
      where: prairie.state_code == ^state_code
  end

  def in_prairie(queryable, %LMPrairie{id: id}) do
    from bison in queryable,
      where: bison.prairie_id == ^id
  end

  def with_last_appointment(queryable) do
    if has_named_binding?(queryable, :last_appointment) do
      queryable
    else
      start_range = six_months_ago()
      end_range = now()

      appointment_subq =
        from(
          appointment in Appointment,
          group_by: [appointment.bison_id, appointment.id],
          where: appointment.appointment_at >= ^start_range,
          where: appointment.appointment_at <= ^end_range,
          order_by: [desc: appointment.appointment_at]
        )

      from b in queryable,
        left_join: last_appointment in subquery(appointment_subq), as: :last_appointment,
        on: last_appointment.bison_id == b.id
    end
  end

  def by_nil_last_appointment(query) do
    from [bison, last_appointment: last_appointment] in query,
      where: is_nil(last_appointment)
  end


  ###########################################

  defp six_months_ago() do
    now()
    |> Timex.shift(months: -6)
  end

  defp now() do
    Timex.now()
  end
end
