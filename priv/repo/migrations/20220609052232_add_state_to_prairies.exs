defmodule Prairie.Repo.Migrations.AddStateToPrairies do
  use Ecto.Migration

  def change do
    alter table(:prairies) do
      add :state_code, :string, default: "NE"
    end
  end
end
