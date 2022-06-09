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
alias Prairie.Bison.Bison
alias Prairie.Veterinary.StaffMember, as: VeterinaryStaffMember
alias Prairie.Veterinary.Record, as: VeterinaryRecord

prairie_1 = Repo.insert!(%LPrairie{name: "Pokorny Prairie", state_code: "NE"})
prairie_2 = Repo.insert!(%LPrairie{name: "Gjerloff Prairie", state_code: "KS"})

bison_1 = Repo.insert!(%Bison{name: "Belinda", age: 1, prairie_id: prairie_1.id})
bison_2 = Repo.insert!(%Bison{name: "Bellerophon", age: 2, prairie_id: prairie_2.id})
bison_3 = Repo.insert!(%Bison{name: "Balthazar", age: 3, prairie_id: prairie_1.id})
bison_4 = Repo.insert!(%Bison{name: "Brianna", age: 3, prairie_id: prairie_2.id})
bison_5 = Repo.insert!(%Bison{name: "Bryce", age: 5, prairie_id: prairie_1.id})

veterinary_staff_1 = Repo.insert!(%VeterinaryStaffMember{name: "Valentina Vega", prairie_id: prairie_1.id})
veterinary_staff_2 = Repo.insert!(%VeterinaryStaffMember{name: "Victor Vaughn", prairie_id: prairie_2.id})

record_1 = Repo.insert!(%VeterinaryRecord{notes: "Stubbed hoof. Gave her an ice pack and a hug. She seems okay now.", bison_id: bison_1.id, veterinary_staff_member_id: veterinary_staff_1.id})

record_1 = Repo.insert!(%VeterinaryRecord{notes: "Accidentally ate a bee. He'll be okay.", bison_id: bison_2.id, veterinary_staff_member_id: veterinary_staff_2.id})
