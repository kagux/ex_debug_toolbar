defmodule ExDebugToolbar.Data.MapTest do
  use ExUnit.Case, async: true
  alias ExDebugToolbar.Data.{Collectable, Collection}

  test "implements collecable protocol" do
    assert Collectable.init_collection(%{}) == %{}
  end

  test "implements collection protocol" do
    assert Collection.change(%{}, %{foo: :bar}) == %{foo: :bar}
  end

  test "it overwrites collection values" do
    collection = %{key: "old value", foo: :bar}
    updated_collection = Collection.change(collection, %{key: "new value"})
    assert updated_collection == %{key: "new value", foo: :bar}
  end
end
