defmodule ExDebugToolbar.RequestTest do
  use ExUnit.Case, async: true
  alias ExDebugToolbar.Request.Event
  alias ExDebugToolbar.Request

  describe "start_event/3" do
    test "adds new event" do
      request = %Request{events: []} |> Request.start_event("event")
      assert request.events |> length == 1
      event = request.events |> hd
      assert event.name == "event"
      assert_in_delta :os.system_time(:micro_seconds), DateTime.to_unix(event.started_at, :microsecond), 5000
    end

    test "attaches metadata" do
      request = %Request{events: []} |> Request.start_event("event", foo: :bar)
      event = request.events |> hd
      assert event.metadata == %{foo: :bar}
    end
  end

  describe "finish_event/2" do
    test "it updates event with finish time and duration" do
      started_at = DateTime.utc_now
      event = %Event{name: "event", started_at: started_at}
      events = [%Event{}, event, %Event{}]
      request = %Request{events: events} |> Request.finish_event("event")
      [_, event, _] = request.events
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
end
