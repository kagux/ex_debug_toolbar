defmodule ExDebugToolbar.ToolbarTest do
  use ExDebugToolbar.CollectorCase, async: true
  alias ExDebugToolbar.Toolbar

  describe "add_data/3" do
    setup :start_request

    test "it returns error on attempt to add to undefined collection" do
      assert {:error, :undefined_collection} = Toolbar.add_data(@request_id, :whoami, %{foo: :bar})
    end

    test "it adds new data to defined collection" do
      Toolbar.add_data(@request_id, :conn, {:request, %Plug.Conn{request_path: "/path"}})
      {:ok, request} = get_request()
      assert request.conn.request_path == "/path"
    end
  end
end
