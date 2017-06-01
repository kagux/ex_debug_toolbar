defmodule ExDebugToolbar.Collector.EctoCollectorTest do
  use ExDebugToolbar.CollectorCase, async: false
  alias ExDebugToolbar.Collector.EctoCollector, as: Collector
  alias ExDebugToolbar.Data.Timeline.Event

  setup :start_request

  test "adds a query execution event" do
    %Ecto.LogEntry{decode_time: 5,query_time: 10, queue_time: 15} |> Collector.log
    assert {:ok, request} = get_request()
    assert request.timeline.events |> Enum.any?
    assert request.timeline.duration == 30
    assert %Event{name: "ecto.query"} = request.timeline.events |> hd
  end

  test "adds query to ecto queries collection" do
    %Ecto.LogEntry{query: "query"} |> Collector.log
    assert {:ok, request} = get_request()
    assert request.ecto.queries |> length == 1
    assert %{query: "query"} = request.ecto.queries |> hd
  end
end
