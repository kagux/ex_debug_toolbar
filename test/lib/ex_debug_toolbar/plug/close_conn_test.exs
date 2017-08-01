defmodule ExDebugToolbar.Plug.CloseConnTest do
  use ExUnit.Case, async: true
  alias Plug.Conn
  alias ExDebugToolbar.Plug.CloseConn

  test "it closes the connection" do
    conn = %Conn{} |> CloseConn.call(%{})
    assert Conn.get_resp_header(conn, "connection") == ["close"]
  end

  test "it closes the connection even if it was keep alive" do
    conn = %Conn{}
    |> Conn.put_req_header("connection", "keep-alive")
    |> CloseConn.call(%{})
    assert Conn.get_resp_header(conn, "connection") == ["close"]
  end
end
