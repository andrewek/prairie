defmodule Prairie.LandManagement.PrairieRepo do
  @moduledoc """
  Get everything we might need from a prairie
  """

  use GenericRepo,
    schema: Prairie.LandManagement.Prairie,
    default_preloads: [bison: [], veterinary_staff_members: []],
    only: [:get, :insert, :update]
end
