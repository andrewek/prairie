defmodule Prairie.Repo.Migrations.CreateVeterinaryRecords do
  use Ecto.Migration

  def change do
    create table(:veterinary_records, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :notes, :text
      add :bison_id, references(:bison, on_delete: :nothing, type: :binary_id)
      add :veterinary_staff_member_id, references(:veterinary_staff_members, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:veterinary_records, [:bison_id])
    create index(:veterinary_records, [:veterinary_staff_member_id])
  end
end
