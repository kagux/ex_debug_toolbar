defmodule ExDebugToolbar.Dashboard.RequestControllerTest do
  use ExDebugToolbar.ConnCase, async: false

  setup :start_request

  describe "index/2" do
    test "it renders", %{conn: conn} do
      conn = get conn, "/"
      assert conn.status == 200
    end

    test "it renders stopped requests", %{conn: conn} do
      stop_request(@request_id)

      conn = get conn, "/"
      {:ok, request} = get_request(@request_id)

      assert conn.assigns.requests == [request]
    end

    test "it doesn't render requests in progress", %{conn: conn} do
      conn = get conn, "/"
      assert conn.assigns.requests == []
    end
  end
end
