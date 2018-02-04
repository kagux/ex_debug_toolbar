defmodule ExDebugToolbar.View.Helpers.TimelineHelpers do
  @moduledoc false
  alias ExDebugToolbar.Data.Timeline

  @timeline_colors ~w(
    bg-blue
    bg-yellow
    bg-purple
    bg-grey-active
  )

  def group_events_own_durations(%Timeline{duration: 0}), do: []
  def group_events_own_durations(%Timeline{} = timeline) do
    colors = Stream.cycle(@timeline_colors)
    timeline
    |> Timeline.group_own_durations
    |> Stream.zip(colors)
    |> Enum.map(fn {{name, duration}, color} ->
      percentage = round(duration / timeline.duration * 100)
      {name, duration, percentage, color}
    end)
  end
end
