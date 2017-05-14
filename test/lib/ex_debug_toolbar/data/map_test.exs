defmodule ExDebugToolbar.Data.MapTest do
  use ExUnit.Case, async: true
  alias ExDebugToolbar.Data.Collectable

  test "implements collecable protocol" do
    assert Collectable.init_container(%{}) == %{}
    assert Collectable.put(%{foo: :bar}, %{}) == %{foo: :bar}
  end

  test "it overwrites container values" do
    container = %{key: "old value", foo: :bar}
    updated_container = Collectable.put(%{key: "new value"}, container)
    assert updated_container == %{key: "new value", foo: :bar}
  end
end
