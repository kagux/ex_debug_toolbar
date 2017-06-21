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
    assert {%{query: "query"}, _, _} = request.ecto |> hd
  end

  test "it marks query as inline when there is no caller_pid" do
    %Ecto.LogEntry{query: "query"} |> Collector.log
    assert {:ok, request} = get_request()
    assert {_, _, :inline} = request.ecto |> hd
  end

  test "it marks query as inline when caller_pid is same process" do
    %Ecto.LogEntry{query: "query"} |> Map.put(:caller_pid, self()) |> Collector.log
    assert {:ok, request} = get_request()
    assert {_, _, :inline} = request.ecto |> hd
  end

  describe "parallel preload" do
    setup do
      pid = self()
      spawn fn ->
        %Ecto.LogEntry{query: "query", query_time: 10}
        |> Map.put(:caller_pid, pid)
        |> Collector.log
        send pid, :done
      end
      result = receive do
        :done -> :ok
      after
        200 -> :error
      end
      {:ok, request} = get_request()

      {result, request: request}
    end

    test "adds query to correct request when it's has caller_pid", context do
      assert context.request.ecto |> length > 0
    end

    test "it adds this query to timeline without duration", context do
      assert context.request.timeline.events |> length == 1
      assert context.request.timeline.duration == 10
    end

    test "it marks query as parallel", context do
      assert {_, _, :parallel} = context.request.ecto |> hd
    end
  end
end
