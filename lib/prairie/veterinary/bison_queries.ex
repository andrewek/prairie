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

  ####### Time Helpers ##############

  defp now() do
    Timex.now()
  end

  defp six_months_ago() do
    now()
    |> Timex.shift(months: -6)
  end
end
