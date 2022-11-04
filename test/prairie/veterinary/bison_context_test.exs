defmodule Prairie.Veterinary.BisonContextTest do
  use Prairie.DataCase, async: true

  import Prairie.Factory

  alias Prairie.Bison.Bison
  alias Prairie.Veterinary.BisonContext

  setup do
    prairie = insert(:prairie)
    staff = insert(:staff_member, prairie: prairie)
    bison = insert(:bison, prairie: prairie)

    %{
      prairie: prairie,
      staff_member: staff,
      bison: bison
    }
  end

  describe "needs_to_schedule/0" do
    test "includes any with no upcoming appointment", %{bison: %Bison{id: id}} do
      result = BisonContext.needs_to_schedule()

      assert [^id] = ids(result)
    end

    test "ignores with an upcoming appointment", %{bison: bison} do
      insert(
        :appointment,
        bison: bison,
        appointment_at: time_from_now(days: 1)
      )

      assert [] == BisonContext.needs_to_schedule()
    end

    test "sorts by 'urgency' of distance from past", %{bison: bison_1} do
      # No recent appointment - get this one in ASAP!
      bison_4 = insert(:bison)
      insert(:appointment, bison: bison_1, appointment_at: time_from_now(months: -7))

      bison_2 = insert(:bison)
      insert(:appointment, bison: bison_2, appointment_at: time_from_now(months: -1))

      bison_3 = insert(:bison)
      insert(:appointment, bison: bison_3, appointment_at: time_from_now(months: -4))

      result = BisonContext.needs_to_schedule()

      # In order: No recent appointment (4), 7 months ago (1), 4 months ago (3), 1 month ago (2)
      assert [bison_4.id, bison_1.id, bison_3.id, bison_2.id] == ids(result)
    end
  end

  describe "overdue_for_appointment/0" do
    test "gets bison with long-ago appointment", %{bison: bison, staff_member: staff_member} do
      insert(
        :appointment,
        bison: bison,
        staff_member: staff_member,
        appointment_at: time_from_now(months: -7)
      )

      result = BisonContext.overdue_for_appointment()

      assert id_in?(result, bison.id)
    end

    test "ignores bison with recent appointments", %{bison: bison, staff_member: staff_member} do
      insert(
        :appointment,
        bison: bison,
        staff_member: staff_member,
        appointment_at: time_from_now(minutes: -1)
      )

      insert(
        :appointment,
        bison: bison,
        staff_member: staff_member,
        appointment_at: time_from_now(months: -7)
      )

      # This shaggy buddy came in just now - no follow-up needed
      assert Enum.empty?(BisonContext.overdue_for_appointment())
    end

    test "gets bison with no appointment", %{bison: bison} do
      result = BisonContext.overdue_for_appointment()

      assert id_in?(result, bison.id)
    end
  end

  describe "overdue_for_appointment/1" do
    test "filters bison by prairie", %{bison: %Bison{id: bison_id}, prairie: prairie} do
      other_prairie = insert(:prairie)
      %Bison{id: other_bison_id} = insert(:bison, prairie: other_prairie)

      result_1 = BisonContext.overdue_for_appointment(prairie)
      assert [^bison_id] = ids(result_1)

      result_2 = BisonContext.overdue_for_appointment(other_prairie)
      assert [^other_bison_id] = ids(result_2)
    end

    test "when filtering by prairie, ignores bison with recent appt", %{
      bison: bison,
      staff_member: staff_member,
      prairie: prairie
    } do
      insert(
        :appointment,
        bison: bison,
        staff_member: staff_member,
        appointment_at: time_from_now(minutes: -1)
      )

      result = BisonContext.overdue_for_appointment(prairie)

      assert Enum.empty?(result)
    end

    test "filters bison by state code", %{bison: %Bison{id: bison_id}, prairie: prairie} do
      other_prairie = insert(:prairie, state_code: "CA")
      %Bison{id: other_bison_id} = insert(:bison, prairie: other_prairie)

      assert id_in?(BisonContext.overdue_for_appointment(prairie.state_code), bison_id)
      assert id_in?(BisonContext.overdue_for_appointment(other_prairie.state_code), other_bison_id)
    end
  end

  #### Convenience Helpers ##############

  # Sometimes we just want some IDs.
  defp ids(collection) do
    Enum.map(collection, fn el -> el.id end)
  end

  # Do we have the thing we want? One can only hope!
  defp id_in?(collection, id) do
    id in ids(collection)
  end

  # Convenience method - call like this:
  #
  # time_from_now([months: 19, minutes: 7])
  #
  # Then you'll get a DateTime 19 months and 7 minutes in the future
  #
  # Or time_from_now([days: -3]) will give you 3 days ago
  defp time_from_now(attrs) do
    Timex.now()
    |> Timex.shift(attrs)
  end
end
