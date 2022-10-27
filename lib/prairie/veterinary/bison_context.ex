defmodule Prairie.Veterinary.BisonContext do
  @moduledoc """
  We'll handle a number of concerns here around bison and their veterinary records.
  """

  import Ecto.Query

  alias Prairie.Bison.Bison
  alias Prairie.Bison.Repo, as: BisonRepo
  alias Prairie.Veterinary.Appointment
  alias Prairie.Veterinary.StaffMember
  alias Prairie.LandManagement.Prairie

  @doc """
  A bison is due for appointment if they haven't had an appointment in the last
  6 months. Bison need semi-annual wellness checks to ensure maximum health and
  shagginess.

  This set of methods returns the list of bison who are due for an appointment,
  but gives you the entire list, or the list filtered by just one prairie, or
  the list filtered by just one veterinarian.
  """
  def due_for_appointment() do
    start_range = six_months_ago()
    end_range = now()

    appointment_subq = from(
      appointment in Appointment,
      group_by: [appointment.bison_id, appointment.id],
      where: appointment.appointment_at >= ^start_range,
      where: appointment.appointment_at <= ^end_range,
      order_by: [desc: appointment.appointment_at]
    )

    BisonRepo.all(
      from b in Bison,
      left_join: appointment in subquery(appointment_subq),
      on: appointment.bison_id == b.id,
      where: is_nil(appointment)
    )
  end

  def due_for_appointment(%Prairie{id: prairie_id} = _prairie) do
    start_range = six_months_ago()
    end_range = now()

    appointment_subq = from(
      appointment in Appointment,
      group_by: [appointment.bison_id, appointment.id],
      where: appointment.appointment_at >= ^start_range,
      where: appointment.appointment_at <= ^end_range,
      order_by: [desc: appointment.appointment_at]
    )

    BisonRepo.all(
      from b in Bison,
      left_join: appointment in subquery(appointment_subq),
      on: appointment.bison_id == b.id,
      where: is_nil(appointment),
      where: b.prairie_id == ^prairie_id
    )
  end

  def due_for_appointment(state_code) when is_binary(state_code) do
    start_range = six_months_ago()
    end_range = now()

    appointment_subq = from(
      appointment in Appointment,
      group_by: [appointment.bison_id, appointment.id],
      where: appointment.appointment_at >= ^start_range,
      where: appointment.appointment_at <= ^end_range,
      order_by: [desc: appointment.appointment_at]
    )

    BisonRepo.all(
      from b in Bison,
      left_join: appointment in subquery(appointment_subq),
      on: appointment.bison_id == b.id,
      where: is_nil(appointment),
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
