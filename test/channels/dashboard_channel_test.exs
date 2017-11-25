defmodule ExDebugToolbar.DashboardChannelTest do
  use ExDebugToolbar.ChannelCase, async: true
  alias ExDebugToolbar.DashboardChannel

  test "joinining the channel" do
    {:ok, _, _} = subscribe_and_join_dashboard()
  end

  describe "handling request events" do
    setup :start_request

    test "pushes request to the socket on request:created event" do
      {:ok, _, socket} = subscribe_and_join_dashboard()
      broadcast_from socket, "request:created", %{id: @request_id}
      {:ok, request} = get_request(@request_id)
      assert_push "request:created", %{html: _, request: ^request}
    end

    test "pushes request to the socket on request:deleted event" do
      {:ok, _, socket} = subscribe_and_join_dashboard()
      broadcast_from socket, "request:deleted", %{id: @request_id}
      assert_push "request:deleted", %{id: @request_id}
    end
  end

  defp subscribe_and_join_dashboard do
    socket() |> subscribe_and_join(DashboardChannel, "dashboard")
  end
end
