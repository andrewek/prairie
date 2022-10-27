defmodule Prairie.Veterinary.Appointment do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "veterinary_appointments" do
    field :appointment_at, :utc_datetime
    belongs_to :bison, Prairie.Bison.Bison
    belongs_to :staff_member, Prairie.Veterinary.StaffMember

    timestamps()
  end

  @doc false
  def changeset(appointment, attrs) do
    appointment
    |> cast(attrs, [:appointment_at])
    |> put_assoc(:bison, attrs.bison)
    |> put_assoc(:staff_member, attrs.staff_member)
    |> validate_required([:appointment_at])
  end
end
