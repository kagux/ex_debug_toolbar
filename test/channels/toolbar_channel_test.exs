defmodule ExDebugToolbar.ToolbarChannelTest do
  use ExDebugToolbar.ChannelCase, async: true
  alias ExDebugToolbar.ToolbarChannel

  setup :start_request

  describe "join" do
    test "it returns stopped request upon joining toolbar channel" do
      stop_request(@request_id)
      {:ok, payload, _} = subscribe_and_join_toolbar(@request_id)
      assert %{} = payload
      assert payload |> Map.has_key?(:html)
      assert payload.uuid == @request_id
    end

    test "it returns pending message if request is still running" do
      {:ok, payload, _} = subscribe_and_join_toolbar(@request_id)
      assert :pending == payload
    end

    test "it returns an error if request could not be retrieved" do
      {:error, error} = subscribe_and_join_toolbar("wrong_id")
      assert %{reason: :not_found} = error
    end
  end

  test "pushes request to the socket on request:created event" do
    {:ok, _, socket} = subscribe_and_join_toolbar(@request_id)
    broadcast_from socket, "request:created", %{id: @request_id}
    {:ok, request} = get_request(@request_id)
    assert_push "request:created", %{html: _, request: ^request}
  end

  defp subscribe_and_join_toolbar(request_id) do
    socket() |> subscribe_and_join(ToolbarChannel, "toolbar:request:#{request_id}", %{})
  end
end
