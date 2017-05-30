defmodule ExDebugToolbar.Data.ConnTest do
  use ExUnit.Case, async: true
  alias ExDebugToolbar.Data.{Collection, Conn}

  describe "collection protocol" do
    setup do
      conn = %Plug.Conn{
      }
      {:ok, conn: conn}
    end

    test "format_item/2 formats ip on request" do
      conn = %Plug.Conn{remote_ip: {127, 0, 0, 1}}
      assert %{remote_ip: "127.0.0.1"} = Collection.format_item(%Conn{}, {:request, conn})
    end

    test "format_item/2 handles empty ip on request" do
      conn = %Plug.Conn{remote_ip: nil}
      assert %{remote_ip: nil} = Collection.format_item(%Conn{}, {:request, conn})
    end

    test "format_item/2 takes req_headers on request" do
      conn = %Plug.Conn{req_headers: [{:foo, :bar}]}
      assert %{req_headers: [{:foo, :bar}]} = Collection.format_item(%Conn{}, {:request, conn})
    end

    test "format_item/2 takes resp_headers on response" do
      conn = %Plug.Conn{resp_headers: [{:foo, :bar}]}
      assert %{resp_headers: [{:foo, :bar}]} = Collection.format_item(%Conn{}, {:response, conn})
    end
  end
end

