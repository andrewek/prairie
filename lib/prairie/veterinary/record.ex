defmodule Prairie.Veterinary.Record do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "veterinary_records" do
    field :notes, :string
    belongs_to :bison, Prairie.Bison.Bison
    belongs_to :veterinary_staff_member, Prairie.Veterinary.StaffMember

    timestamps()
  end

  @doc false
  def changeset(record, attrs) do
    record
    |> cast(attrs, [:notes, :bison_id, :veterinary_staff_member_id])
    |> validate_required([:notes, :bison_id, :veterinary_staff_member_id])
  end
end
