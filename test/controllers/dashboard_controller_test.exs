defmodule ExDebugToolbar.DashboardControllerTest do
  use ExDebugToolbar.ConnCase, async: true

  setup :insert_request

  describe "show/2" do
    test "it renders", %{conn: conn} do
      conn = get conn, "/"
      assert conn.status == 200
    end
  end
end
