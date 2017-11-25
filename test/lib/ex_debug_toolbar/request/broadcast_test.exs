defmodule ExDebugToolbar.Request.BroadcastTest do
  use ExDebugToolbar.ChannelCase, async: false # cannot pin why setting this to true blows up
  alias ExDebugToolbar.Request.Broadcast

  setup :start_request

  describe "request_created/0" do
    setup :subscribe_to_topic

    for topic <- ~w(dashboard toolbar)a do
      @tag topic: topic
      test "it broadcasts stopped request to #{topic} channel topic" do
        stop_request(@request_id)
        Broadcast.request_created()
        assert_broadcast "request:created", %{id: @request_id}
      end

      @tag topic: topic
      test "it does nothing on #{topic} channel topic when request is not stopped" do
        Broadcast.request_created()
        refute_broadcast "request:created", %{}
      end

      @tag topic: topic
      test "it does nothing on #{topic} channel topic when request does not exist" do
        delete_request(@request_id)
        Broadcast.request_created()
        refute_broadcast "request:created", %{}
      end
    end

    defp subscribe_to_topic(%{topic: :toolbar}) do
      @endpoint.subscribe("toolbar:request:#{@request_id}")
    end
    defp subscribe_to_topic(%{topic: :dashboard}) do
      @endpoint.subscribe("dashboard")
    end
  end
end
