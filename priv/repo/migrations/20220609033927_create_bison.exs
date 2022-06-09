defmodule Prairie.Repo.Migrations.CreateBison do
  use Ecto.Migration

  def change do
    create table(:bison, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :age, :integer
      add :prairie_id, references(:prairies, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:bison, [:prairie_id])
  end
end
