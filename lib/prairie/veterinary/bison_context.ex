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
  A bison is due to schedule an appointment if they have no future appointment scheduled.

  Bison are sorted by their most recent appointment
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

    BisonRepo.all(
      from b in Bison,
        left_join: last_appointment in subquery(appointment_subq),
        on: last_appointment.bison_id == b.id,
        where: is_nil(last_appointment)
    )
  end

  def overdue_for_appointment(%LMPrairie{id: prairie_id} = _prairie) do
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

    BisonRepo.all(
      from b in Bison,
        left_join: last_appointment in subquery(appointment_subq),
        on: last_appointment.bison_id == b.id,
        where: is_nil(last_appointment),
        where: b.prairie_id == ^prairie_id
    )
  end

  def overdue_for_appointment(state_code) when is_binary(state_code) do
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

    BisonRepo.all(
      from b in Bison,
        left_join: last_appointment in subquery(appointment_subq),
        on: last_appointment.bison_id == b.id,
        where: is_nil(last_appointment),
        join: prairie in assoc(b, :prairie),
        where: prairie.state_code == ^state_code
    )
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
