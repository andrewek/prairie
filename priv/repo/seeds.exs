# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Prairie.Repo.insert!(%Prairie.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Prairie.Repo
alias Prairie.LandManagement.Prairie, as: LPrairie

prairie_1 = Repo.insert!(%LPrairie{name: "Pokorny Prairie"})
prairie_2 = Repo.insert!(%LPrairie{name: "Gjerloff Prairie"})
prairie_3 = Repo.insert!(%LPrairie{name: "Lincoln Creek Prairie"})
