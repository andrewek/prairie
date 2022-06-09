defmodule Prairie.Repo.Migrations.CreateVeterinaryStaffMembers do
  use Ecto.Migration

  def change do
    create table(:veterinary_staff_members, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :prairie_id, references(:prairies, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:veterinary_staff_members, [:prairie_id])
  end
end
