defmodule Prairie.Bison.ContextTest do
  use Prairie.DataCase, async: true

  import Prairie.Factory
  alias Prairie.Bison.Bison
  alias Prairie.Bison.Context, as: BisonContext

  setup do
    prairie = insert(:prairie)
    bison = insert(:bison, prairie: prairie)

    %{
      prairie: prairie,
      bison: bison
    }
  end

  describe "all/0" do
    test "gets all", %{bison: %Bison{id: bison_id}} do
      assert [%Bison{id: ^bison_id}] = BisonContext.all()
    end
  end

  describe "get/1" do
    test "gets one", %{bison: %Bison{id: bison_id}} do
      assert {:ok, %Bison{id: ^bison_id}} = BisonContext.get(bison_id)
    end

    test "gets none" do
      assert {:error, Bison, :not_found} = BisonContext.get(Ecto.UUID.generate())
    end
  end

  describe "by_prairie/1" do
    test "gets results", %{bison: %Bison{id: bison_id}, prairie: prairie} do
      other_prairie = insert(:prairie)
      %Bison{id: other_bison_id} = insert(:bison, prairie: other_prairie)

      assert [%Bison{id: ^bison_id}] = BisonContext.by_prairie(prairie)
      assert [%Bison{id: ^other_bison_id}] = BisonContext.by_prairie(other_prairie)
    end
  end

  describe "by_name/1" do
    setup do
      %{
        brenda: insert(:bison, name: "Brenda Bison"),
        biff: insert(:bison, name: "Biff Bison")
      }
    end

    test "matches case-insensitive", %{brenda: %Bison{id: brenda_id}} do
      assert [%Bison{id: ^brenda_id}] = BisonContext.by_name("bReNdA BiSoN")
    end

    test "matches partial", %{brenda: %Bison{id: brenda_id}, biff: %Bison{id: biff_id}} do
      result = BisonContext.by_name("bison")
      ids = Enum.map(result, fn el -> el.id end)

      assert brenda_id in ids
      assert biff_id in ids
    end
  end

  describe "by_state_code/1" do
    test "gets some", %{prairie: prairie, bison: bison} do
      same_state_prairie = insert(:prairie, state_code: prairie.state_code)
      same_state_bison = insert(:bison, prairie: same_state_prairie)

      other_state_prairie = insert(:prairie, state_code: "ZZ")
      other_state_bison = insert(:bison, prairie: other_state_prairie)

      result_ids =
        BisonContext.by_state_code(prairie.state_code)
        |> Enum.map(fn el -> el.id end)

      assert bison.id in result_ids
      assert same_state_bison.id in result_ids
      refute other_state_bison.id in result_ids
    end
  end
end
