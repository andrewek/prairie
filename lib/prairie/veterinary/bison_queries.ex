defmodule Prairie.Veterinary.BisonQueries do
  @moduledoc """
  Composable Ecto Queries for getting some news about our bison friends
  """

  import Ecto.Query

  alias Prairie.Bison.Bison
  alias Prairie.Veterinary.Appointment
  alias Prairie.LandManagement.Prairie, as: LMPrairie

  def base_query() do
    from(bison in Bison)
  end

  def by_age_at_least(queryable, age) do
    from bison in queryable,
      where: bison.age >= ^age
  end

  def by_age_at_most(queryable, age) do
    from bison in queryable,
      where: bison.age <= ^age
  end

  def by_age_between(queryable, min_age, max_age) do
    queryable
    |> by_age_at_least(min_age)
    |> by_age_at_most(max_age)
  end

  ####### Time Helpers ##############

  defp now() do
    Timex.now()
  end

  defp six_months_ago() do
    now()
    |> Timex.shift(months: -6)
  end
end
