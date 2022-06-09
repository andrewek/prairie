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
    field :state_code, :string, default: "NE"

    has_many :bison, Prairie.Bison.Bison
    has_many :veterinary_staff_members, Prairie.Veterinary.StaffMember

    timestamps()
  end

  @doc false
  def changeset(prairie \\ %Prairie.LandManagement.Prairie{}, attrs) do
    prairie
    |> cast(attrs, [:name, :state_code])
    |> validate_required([:name, :state_code])
  end
end
