defmodule ExDebugToolbar.Collector.EctoCollectorTest do
  use ExUnit.Case, async: false
  use Plug.Test
  alias ExDebugToolbar.Collector.EctoCollector, as: Collector
  alias ExDebugToolbar.Data.Timeline.Event
  import ExDebugToolbar.Test.Support.RequestHelpers

  @request_id "request_id"

  setup_all do
    delete_all_requests()
  end

  setup do
    Process.put(:request_id, @request_id)
    on_exit &delete_all_requests/0
    start_request()
    :ok
  end

  test "adds a query execution event" do
    %Ecto.LogEntry{decode_time: 5,query_time: 10, queue_time: 15} |> Collector.log
    assert {:ok, request} = get_request()
    assert request.data.timeline.events |> Enum.any?
    assert request.data.timeline.duration == 30
    assert %Event{name: "ecto.query"} = request.data.timeline.events |> hd
  end

  test "adds query to ecto queries collection" do
    %Ecto.LogEntry{query: "query"} |> Collector.log
    assert {:ok, request} = get_request()
    assert request.data |> Map.has_key?(:ecto)
    assert request.data.ecto |> length == 1
    assert %{query: "query"} = request.data.ecto |> hd
  end
end
