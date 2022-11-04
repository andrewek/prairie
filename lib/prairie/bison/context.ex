defmodule Prairie.Bison.Context do
  @moduledoc """
  Let's get some Bison!
  """

  alias Prairie.Bison.Repo, as: BisonRepo
  alias Prairie.Bison.Bison
  alias Prairie.LandManagement.Prairie, as: LMPrairie

  import Ecto.Query

  def all() do
    BisonRepo.all()
  end

  def get(id) do
    BisonRepo.get(id)
  end

  def by_prairie(%LMPrairie{id: prairie_id}) do
    BisonRepo.all(
      from bison in Bison,
        where: bison.prairie_id == ^prairie_id
    )
  end

  def by_name(name) do
    name_str = "%#{name}%"

    BisonRepo.all(
      from bison in Bison,
        where: ilike(bison.name, ^name_str)
    )
  end

  def by_age_between(start_age, end_age) do
    BisonRepo.all(
      from bison in Bison,
        where: bison.age >= ^start_age,
        where: bison.age <= ^end_age
    )
  end

  def by_state_code(state_code) do
    BisonRepo.all(
      from bison in Bison,
        join: prairie in assoc(bison, :prairie),
        where: prairie.state_code == ^state_code
    )
  end
end
