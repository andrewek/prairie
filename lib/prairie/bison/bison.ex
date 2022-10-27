defmodule Prairie.Bison.Bison do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "bison" do
    field :age, :integer
    field :name, :string

    belongs_to :prairie, Prairie.LandManagement.Prairie

    timestamps()
  end

  @doc false
  def changeset(bison, attrs) do
    bison
    |> cast(attrs, [:name, :age, :prairie_id])
    |> validate_required([:name, :age, :prairie_id])
  end
end
