defmodule ExDebugToolbar.View.Helpers.TimelineHelpersTest do
  use ExUnit.Case, async: true
  alias ExDebugToolbar.View.Helpers.TimelineHelpers
  alias ExDebugToolbar.Data.Timeline

  describe "group_events_own_durations/1" do
    test "returns empty list if timeline duration is 0" do
      groups = TimelineHelpers.group_events_own_durations(%Timeline{duration: 0})
      assert groups == []
    end

    test "returns groups with percentage and colors" do
      timeline = %Timeline{duration: 1000, events: [
        %Timeline.Event{name: "group1", own_duration: 250},
        %Timeline.Event{name: "group2", own_duration: 750},
      ]}
      [group_a, group_b] = TimelineHelpers.group_events_own_durations(timeline)
      assert {"Group1", 250, 25, _} = group_a
      assert {"Group2", 750, 75, _} = group_b
    end
  end
end
