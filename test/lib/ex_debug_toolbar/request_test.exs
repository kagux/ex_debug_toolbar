defmodule ExDebugToolbar.RequestTest do
  use ExUnit.Case, async: true
  alias ExDebugToolbar.Request.{Event, LogEntry}
  alias ExDebugToolbar.Request

  describe "start_event/3" do
    test "adds first event" do
      %{timeline: event} = %Request{} |> Request.start_event("event")
      assert %Event{} = event
      assert event.name == "event"
      assert_in_delta :os.system_time(:micro_seconds), DateTime.to_unix(event.started_at, :microsecond), 5000
    end

    test "attaches metadata" do
      request = %Request{} |> Request.start_event("event", foo: :bar)
      assert request.timeline.metadata == %{foo: :bar}
    end
  end

  describe "finish_event/2" do
    test "it updates top event with finish time and duration" do
      started_at = DateTime.utc_now
      event = %Event{name: "event", started_at: started_at}
      request = %Request{timeline: event} |> Request.finish_event("event")
      event = request.timeline
      assert :gt == DateTime.compare(event.finished_at, started_at)
      assert event.duration > 0
    end
  end

  test "put_metadata/3 sets metadata key value" do
    request  = %Request{} |> Request.put_metadata(:foo, :bar)
    assert request.metadata.foo == :bar
  end

  test "get_metadata/3 returns metadata value by key" do
    request = %Request{metadata: %{key: "value"}}
    assert Request.get_metadata(request, :key) == "value"
    assert Request.get_metadata(request, :foo) == nil
    assert Request.get_metadata(request, :foo, "default") == "default"
  end

  test "put_path/1 sets path" do
    request = %Request{} |> Request.put_path("/my_path")
    assert request.path == "/my_path"
  end

  test "add_log_entry/3 adds new log entry to the list" do
    timestamp = {{2000, 1, 1}, {13, 30, 15}}
    metadata = [foo: :bar]
    request = %Request{logs: [%LogEntry{}]} |> Request.add_log_entry({:debug, "log entry", timestamp, metadata})
    log_entry = request.logs |> List.last
    assert %LogEntry{} = log_entry
    assert log_entry.level == :debug
    assert log_entry.message == "log entry"
    assert log_entry.metadata == metadata
    assert log_entry.timestamp == timestamp
  end
end
