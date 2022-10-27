defmodule Prairie.Repo.Migrations.DropVeterinaryRecordsTable do
  use Ecto.Migration

  def change do
    drop_if_exists table("veterinary_records")
  end
end
