defmodule Prairie.Repo.Migrations.CreatePrairies do
  use Ecto.Migration

  def change do
    create table(:prairies, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false

      timestamps()
    end
  end
end
