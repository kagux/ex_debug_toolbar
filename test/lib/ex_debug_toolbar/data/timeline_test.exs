defmodule ExDebugToolbar.Data.TimelineTest do
  use ExUnit.Case, async: true
  alias ExDebugToolbar.Data.Timeline.{Event}
  alias ExDebugToolbar.Data.{Timeline, Collection}

  describe "events management" do
    test "tracks events" do
      timeline =
        %Timeline{}
        |> Timeline.start_event("name")
        |> Timeline.finish_event("name")

      assert timeline.events |> length == 1
      event = timeline.events |> List.first

      assert %Event{} = event
      assert event.name == "name"
      assert event.duration == 0
    end

    test "optionally accepts precalculated event duration" do
      timeline = %Timeline{}
      |> Timeline.start_event("A")
      |> Timeline.finish_event("A", duration: 1000)
      
      assert %{duration: 1000} = timeline.events |> hd
      assert timeline.duration == 1000
    end

    test "optionally accepts start and finish timestamps" do
      timeline = %Timeline{}
      |> Timeline.start_event("A", timestamp: 1000)
      |> Timeline.finish_event("A", timestamp: 1050)
      
      assert %{duration: 50} = timeline.events |> hd
      assert timeline.duration == 50
    end

    test "accepts nested events" do
      timeline =
        %Timeline{}
        |> Timeline.start_event("A")
        |> Timeline.start_event("A-B")
        |> Timeline.finish_event("A-B")
        |> Timeline.start_event("A-B")
        |> Timeline.finish_event("A-B")
        |> Timeline.finish_event("A")
        |> Timeline.start_event("C")
        |> Timeline.start_event("C-D")
        |> Timeline.finish_event("C-D")
        |> Timeline.start_event("C-E")
        |> Timeline.finish_event("C-E")
        |> Timeline.finish_event("C")

      [first_event, second_event] = timeline.events
      assert first_event.name == "C"
      assert first_event.events |> Enum.at(0) |> Map.fetch!(:name) == "C-E"
      assert first_event.events |> Enum.at(1) |> Map.fetch!(:name) == "C-D"

      assert second_event.name == "A"
      assert second_event.events |> Enum.at(0) |> Map.fetch!(:name) == "A-B"
      assert second_event.events |> Enum.at(1) |> Map.fetch!(:name) == "A-B"
    end

    test "raises an error when closing an event that is not open" do
      assert_raise RuntimeError, fn ->
        %Timeline{}
        |> Timeline.start_event("A")
        |> Timeline.finish_event("B")
      end
      assert_raise RuntimeError, fn ->
        %Timeline{}
        |> Timeline.start_event("A")
        |> Timeline.start_event("B")
        |> Timeline.finish_event("C")
      end
    end

    test "raises an error when closing an event that is not the last one opened" do
      assert_raise RuntimeError, fn ->
        %Timeline{}
        |> Timeline.start_event("A")
        |> Timeline.start_event("C")
        |> Timeline.finish_event("A")
      end
    end

    test "adds an event that already happened" do
      timeline = %Timeline{} |> Timeline.add_finished_event("A", 5000)
      assert timeline.events |> length == 1
      assert %Event{name: "A"} = timeline.events |> hd
      assert timeline.duration == 5000
    end
  end

  describe "collection protocol" do
    test "passing :start_event action to add/2 starts new event" do
      timeline = %Timeline{}
      |> Collection.add({:start_event, "event", 12345})
      |> Timeline.finish_event("event")

      assert timeline.events |> length == 1
      assert %Event{name: "event", started_at: 12345} = timeline.events |> hd
    end

    test "passing :finish_event action to add/2 with duration finishes event with that duration" do
      timeline = %Timeline{}
      |> Timeline.start_event("event")
      |> Collection.add({:finish_event, "event", nil, 5})

      assert timeline.events |> length == 1
      assert %Event{name: "event", duration: 5} = timeline.events |> hd
    end

    test "passing :finish_event action to add/2 with timestamp finishes event with relative duration" do
      timeline = %Timeline{}
      |> Timeline.start_event("event", timestamp: 100)
      |> Collection.add({:finish_event, "event", 125, nil})

      assert timeline.events |> length == 1
      assert %Event{name: "event", duration: 25} = timeline.events |> hd
    end

    test "passing :add_finished_event action to add/2 adds event with duration" do
      timeline = %Timeline{}
      |> Collection.add({:add_finished_event, "event", 5})

      assert timeline.events |> length == 1
      assert %Event{name: "event", duration: 5} = timeline.events |> hd
    end
  end

  describe "get_all_events/1" do
    test "returns all events in a list" do
      timeline = %Timeline{events: [
        %Event{name: "depth1", events: [
          %Event{name: "depth2"}
        ]}
      ]}
      event_names = Timeline.get_all_events(timeline) |> Enum.map(&(&1.name))
      assert event_names == ["depth1", "depth2"]
    end
  end
end
