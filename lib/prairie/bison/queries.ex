defmodule Prairie.Bison.Queries do
  @moduledoc """
  Composable queries we might use for fun
  """

  import Ecto.Query
  alias Prairie.Bison.Bison

  def default_query() do
    from(bison in Bison)
  end

  def age_at_least(queryable, age) do
    from bison in queryable,
      where: bison.age >= ^age
  end

  def age_at_most(queryable, age) do
    from bison in queryable,
      where: bison.age <= ^age
  end

  def in_state(queryable, state_code) do
    queryable
    |> with_prairie()
    |> where([_, prairie: prairie], prairie.state_code == ^state_code)
  end

  def with_prairie(queryable) do
    if has_named_binding?(queryable, :prairie) do
      queryable
    else
      from bison in queryable, join: prairie in assoc(bison, :prairie), as: :prairie
    end
  end
end
