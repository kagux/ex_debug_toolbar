defmodule ExDebugToolbar.Collector.EctoCollectorTest do
  use ExDebugToolbar.CollectorCase, async: true
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

  test "it does not keep query result rows" do
    entry = %Ecto.LogEntry{
      query: "query",
      result: {:ok, %Postgrex.Result{ rows: [[:user]]}}
    }
    Collector.log entry
    assert {:ok, request} = get_request()
    {saved_entry, _, _} = request.ecto |> hd
    assert {:ok, result} = saved_entry.result
    assert result.rows == []
  end

  test "it does not change result when it is nil" do
    %Ecto.LogEntry{query: "query", result: nil} |> Collector.log
    assert {:ok, request} = get_request()
    assert {%{result: nil}, _, _} = request.ecto |> hd
  end

  test "it handles query with an error" do
    entry = %Ecto.LogEntry{
      query: "query",
      result: {:error, %Postgrex.Error{}}
    }
    Collector.log entry
    assert {:ok, request} = get_request()
    assert {%{result: {:error, _}}, _, _} = request.ecto |> hd
  end

  test "it converts binary ecto uuid to a string" do
    uuid = <<134, 8, 204, 149, 179, 187, 75, 177, 186, 76, 144, 162, 54, 243, 218, 130>>
    %Ecto.LogEntry{query: "query", params: [uuid]} |> Collector.log
    assert {:ok, request} = get_request()
    assert {%{params: ["8608cc95-b3bb-4bb1-ba4c-90a236f3da82"]}, _, _} = request.ecto |> hd
  end

  test "it replaces binary with a placeholder when it's not a uuid" do
    uuid = <<1, 0>>
    %Ecto.LogEntry{query: "query", params: [uuid]} |> Collector.log
    assert {:ok, request} = get_request()
    assert {%{params: ["__BINARY__"]}, _, _} = request.ecto |> hd
  end

  test "the order of params in a query is preserved" do
    %Ecto.LogEntry{query: "query", params: [1, 2, 3]} |> Collector.log
    assert {:ok, request} = get_request()
    assert {%{params: [1, 2, 3]}, _, _} = request.ecto |> hd
  end

  test "it returns unmodified entry" do
    entry = %Ecto.LogEntry{
      query: "query",
      result: {:ok, %Postgrex.Result{ rows: [[:user]]}}
    }
    assert entry == Collector.log(entry)
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

    test "it does not add this query to timeline", context do
      assert context.request.timeline.events == []
    end

    test "it marks query as parallel", context do
      assert {_, _, :parallel} = context.request.ecto |> hd
    end
  end
end
