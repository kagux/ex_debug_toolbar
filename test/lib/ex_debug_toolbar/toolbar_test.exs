defmodule ExDebugToolbar.ToolbarTest do
  use ExDebugToolbar.CollectorCase, async: false
  alias ExDebugToolbar.Toolbar

  setup_all do
    Toolbar.define_collection(:foo, %{})
  end

  describe "add_data/3" do
    setup :start_request

    test "it returns error on attempt to add to undefined collection" do
      assert {:error, :undefined_collection} = Toolbar.add_data(@request_id, :whoami, %{foo: :bar})
    end

    test "it adds new data to defined collection" do
      Toolbar.add_data(@request_id, :foo, %{foo: :bar})
      {:ok, request} = get_request()
      assert request.data.foo == %{foo: :bar}
    end

    test "it updates existing data in defined collection" do
      Toolbar.add_data(@request_id, :foo, %{foo: :bar})
      Toolbar.add_data(@request_id, :foo, %{faz: :baz})
      {:ok, request} = get_request()
      assert request.data.foo == %{foo: :bar, faz: :baz}
    end
  end
end
