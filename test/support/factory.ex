defmodule Prairie.Factory do
  use ExMachina.Ecto, repo: Prairie.Repo

  def prairie_factory do
    %Prairie.LandManagement.Prairie{
      state_code: "NE",
      name: sequence(:name, &"prairie-#{&1}")
    }
  end

  def bison_factory do
    %Prairie.Bison.Bison{
      age: 4,
      name: sequence(:name, &"bison-#{&1}"),
      prairie: build(:prairie)
    }
  end
end
