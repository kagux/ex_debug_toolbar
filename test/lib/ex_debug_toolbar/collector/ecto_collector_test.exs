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
    assert request.ecto |> length == 1
    assert %{query: "query"} = request.ecto |> hd
  end

  test "adds query to correct request when it's has caller_pid" do
    pid = self()
    spawn fn ->
      %Ecto.LogEntry{query: "query", caller_pid: pid, query_time: 10} |> Collector.log
      send pid, :done
    end

    msg = receive do
      :done -> :ok
    after
      200 -> :error
    end

    assert :ok == msg
    assert {:ok, request} = get_request()
    assert request.ecto |> length > 0
    assert request.timeline.duration == 10
  end
end
