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

  describe "due_for_appointment/1" do
    test "gets bison with long-ago appointment", %{bison: bison, staff_member: staff_member} do
      insert(
        :appointment,
        bison: bison,
        staff_member: staff_member,
        appointment_at: time_ago([months: -7])
      )

      result = BisonContext.due_for_appointment()

      assert id_in?(result, bison.id)
    end

    test "ignores bison with recent appointments", %{bison: bison, staff_member: staff_member} do
      insert(
        :appointment,
        bison: bison,
        staff_member: staff_member,
        appointment_at: time_ago([minutes: -1])
      )

      insert(
        :appointment,
        bison: bison,
        staff_member: staff_member,
        appointment_at: time_ago([months: -7])
      )

      # This shaggy buddy came in just now - no follow-up needed
      assert Enum.empty?(BisonContext.due_for_appointment())
    end

    test "gets bison with no appointment", %{bison: bison} do
      result = BisonContext.due_for_appointment()

      assert id_in?(result, bison.id)
    end

    test "filters bison by prairie", %{bison: %Bison{id: bison_id}, prairie: prairie} do
      other_prairie = insert(:prairie)
      %Bison{id: other_bison_id} = insert(:bison, prairie: other_prairie)

      result_1 = BisonContext.due_for_appointment(prairie)
      assert [^bison_id] = ids(result_1)

      result_2 = BisonContext.due_for_appointment(other_prairie)
      assert [^other_bison_id] = ids(result_2)
    end

    test "when filtering by prairie, ignores bison with recent appt", %{bison: bison, staff_member: staff_member, prairie: prairie} do
      insert(
        :appointment,
        bison: bison,
        staff_member: staff_member,
        appointment_at: time_ago([minutes: -1])
      )

      result = BisonContext.due_for_appointment(prairie)

      assert Enum.empty?(result)
    end

    test "filters bison by state code", %{bison: %Bison{id: bison_id}, prairie: prairie} do
      other_prairie = insert(:prairie, state_code: "CA")
      %Bison{id: other_bison_id} = insert(:bison, prairie: other_prairie)

      assert id_in?(BisonContext.due_for_appointment(prairie.state_code), bison_id)
      assert id_in?(BisonContext.due_for_appointment(other_prairie.state_code), other_bison_id)
    end
  end


  #### Convenience Helpers ##############

  # Sometimes we just want some IDs.
  defp ids(collection) do
    Enum.map(collection, fn(el) -> el.id end)
  end

  # Do we have the thing we want? One can only hope!
  defp id_in?(collection, id) do
    id in ids(collection)
  end

  # Convenience method - call like this:
  #
  # time_ago([months: 19, minutes: 7])
  #
  # Then you'll get a DateTime 19 months and 7 minutes in the past
  #
  # You could also get time in the future if you want, you wacky wizard.
  defp time_ago(attrs) do
    Timex.now()
    |> Timex.shift(attrs)
  end
end
