defmodule ExDebugToolbar.RequestTest do
  use ExUnit.Case, async: true
  alias ExDebugToolbar.Request
  alias Plug.Conn


  describe "#group_similar/1" do
    @conn %Conn{status: 200, method: "get", request_path: "/path"}
    @request %Request{uuid: 1, conn: @conn}

    test "groups similar consequent requests by status" do
      other_request = %{@request | uuid: 2, conn: %{@conn | status: 404}}
      history = [@request, other_request, other_request, @request]
      collapsed_history = [[@request], [other_request, other_request], [@request]] |> to_uuid

      assert history |> Request.group_similar |> to_uuid == collapsed_history
    end

    test "groups similar consequent requests by method" do
      other_request = %{@request | uuid: 2, conn: %{@conn | method: "post"}}
      history = [@request, other_request, other_request, @request]
      collapsed_history = [[@request], [other_request, other_request], [@request]] |> to_uuid

      assert history |> Request.group_similar |> to_uuid == collapsed_history
    end

    test "it group similar requests by path" do
      other_request = %{@request | uuid: 2, conn: %{@conn | request_path: "/other"}}
      history = [@request, @request, other_request, other_request]
      collapsed_history = [[@request, @request], [other_request, other_request]] |> to_uuid

      assert history |> Request.group_similar |> to_uuid == collapsed_history
    end
  end

  defp to_uuid(requests) when is_list(requests) do
    requests |> Enum.map(&to_uuid/1)
  end
  defp to_uuid(%Request{uuid: uuid}), do: uuid
end
