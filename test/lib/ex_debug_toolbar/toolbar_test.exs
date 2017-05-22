defmodule ExDebugToolbar.ToolbarTest do
  use ExDebugToolbar.CollectorCase, async: false
  alias ExDebugToolbar.Toolbar

  describe "add_data/3" do
    setup :start_request

    test "it sets new data" do
      Toolbar.add_data(@request_id, :foo, %{foo: :bar})
      {:ok, request} = get_request()
      assert request.data.foo == %{foo: :bar}
    end

    test "it updates existing data" do
      Toolbar.add_data(@request_id, :foo, %{foo: :bar})
      Toolbar.add_data(@request_id, :foo, %{faz: :baz})
      {:ok, request} = get_request()
      assert request.data.foo == %{foo: :bar, faz: :baz}
    end
  end
end
