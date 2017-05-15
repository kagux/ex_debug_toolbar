defmodule ExDebugToolbar.ToolbarTest do
  use ExUnit.Case, async: true
  alias ExDebugToolbar.Toolbar
  import ExDebugToolbar.Test.Support.RequestHelpers

  describe "add_data/3" do
    test "it sets new data" do
      Process.put(:request_id, "request_id_1")
      Toolbar.start_request
      Toolbar.add_data("request_id_1", :foo, %{foo: :bar})
      {:ok, request} = get_request()
      assert request.data.foo == %{foo: :bar}
    end

    test "it updates existing data" do
      Process.put(:request_id, "request_id_2")
      Toolbar.start_request
      Toolbar.add_data("request_id_2", :foo, %{foo: :bar})
      Toolbar.add_data("request_id_2", :foo, %{faz: :baz})
      {:ok, request} = get_request()
      assert request.data.foo == %{foo: :bar, faz: :baz}
    end
  end
end
