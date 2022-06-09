defmodule Prairie.Veterinary.StaffMember do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "veterinary_staff_members" do
    field :name, :string
    belongs_to :prairie, Prairie.LandManagement.Prairie
    has_many :records, Prairie.Veterinary.Record, foreign_key: :veterinary_staff_member_id

    timestamps()
  end

  @doc false
  def changeset(staff_member, attrs) do
    staff_member
    |> cast(attrs, [:name, :prairie_id])
    |> validate_required([:name, :prairie_id])
  end
end
