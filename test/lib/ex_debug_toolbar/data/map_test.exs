defmodule ExDebugToolbar.Data.MapTest do
  use ExUnit.Case, async: true
  alias ExDebugToolbar.Data.Collection

  describe "collection protocol" do
    test "add/2 sets values in the collection" do
      assert Collection.add(%{}, %{foo: :bar}) == %{foo: :bar}
    end

    test "add/2 overwrites collection values" do
      collection = %{key: "old value", foo: :bar}
      updated_collection = Collection.add(collection, %{key: "new value"})
      assert updated_collection == %{key: "new value", foo: :bar}
    end
  end
end
