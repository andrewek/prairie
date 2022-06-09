defmodule Prairie.Bison.Repo do
  @moduledoc """
  Basic bison access
  """

  use GenericRepo,
    schema: Prairie.Bison.Bison,
    default_preloads: [prairie: []]
end
