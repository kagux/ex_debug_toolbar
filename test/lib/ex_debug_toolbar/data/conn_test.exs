defmodule ExDebugToolbar.Data.ConnTest do
  use ExUnit.Case, async: true
  alias ExDebugToolbar.Data.Collection
  alias Plug.Conn

  describe "collection protocol" do
    setup do
      conn = %Plug.Conn{
      }
      {:ok, conn: conn}
    end

    test "add/2 sets conn on request" do
      conn = %Conn{request_path: "/"}
      assert Collection.add(%Conn{}, {:request, conn}) == conn
    end

    test "add/2 updates values on response" do
      conn = %Conn{resp_headers: []}
      new_conn = %Plug.Conn{resp_headers: [{:foo, :bar}]}
      assert %Conn{resp_headers: [{:foo, :bar}]} = Collection.add(conn, {:response, new_conn})
    end

    test "add/2 does not persist conn body" do
      conn = %Conn{resp_body: "hello"}
      refute Collection.add(%Conn{}, {:request, conn}).resp_body
      refute Collection.add(%Conn{}, {:response, conn}).resp_body
    end
  end
end
