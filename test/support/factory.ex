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

  def staff_member_factory do
    %Prairie.Veterinary.StaffMember{
      prairie: build(:prairie),
      name: sequence(:name, &"staff-#{&1}")
    }
  end

  def appointment_factory do
    %Prairie.Veterinary.Appointment{
      bison: build(:bison),
      staff_member: build(:staff_member),
      appointment_at: Timex.now()
    }
  end
end
