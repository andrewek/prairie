defmodule Prairie.LandManagement.Prairie do
  @moduledoc """
  A Prairie represents a single managed tract of land, to which we attach the
  various residents and management apparatuses.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "prairies" do
    field :name, :string

    has_many :bison, Prairie.Bison.Bison

    timestamps()
  end

  @doc false
  def changeset(prairie \\ %Prairie.LandManagement.Prairie{}, attrs) do
    prairie
    |> cast(attrs, [:name])
    |> validate_required(:name)
  end
end
