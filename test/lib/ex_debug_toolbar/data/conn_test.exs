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

    test "add/2 replaces conn" do
      conn = %Conn{request_path: "/"}
      assert Collection.add(%Conn{}, conn) == conn
    end
  end
end
