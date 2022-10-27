defmodule Prairie.Repo.Migrations.CreateVeterinaryAppointments do
  use Ecto.Migration

  def change do
    create table(:veterinary_appointments, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :appointment_at, :utc_datetime
      add :bison_id, references(:bison, on_delete: :nothing, type: :binary_id)
      add :staff_member_id, references(:veterinary_staff_members, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:veterinary_appointments, [:bison_id])
    create index(:veterinary_appointments, [:staff_member_id])
  end
end
