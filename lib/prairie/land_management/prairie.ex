defmodule Prairie.LandManagement.Prairie do
  @moduledoc """
  A Prairie represents a single managed tract of land, to which we attach the
  various residents and management apparatuses.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "prairies" do
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(prairie \\ %Prairie{}, attrs) do
    prairie
    |> cast(attrs, [:name])
    |> validate_required(:name)
  end
end
