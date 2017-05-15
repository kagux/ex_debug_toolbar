defmodule ExDebugToolbar.Data.Timeline do
  alias ExDebugToolbar.Data.Timeline

  defstruct [
    events: []
  ]

  def duration(%Timeline{} = timeline) do
    timeline.events
    |> Stream.map(&(&1.duration))
    |> Stream.reject(&is_nil/1)
    |> Enum.sum
  end

  def start_event(%Timeline{} = timeline, name) do
    event = %Timeline.Event{name: name, started_at: DateTime.utc_now()}
    %{timeline | events: [event | timeline.events]}
  end

  def finish_event(%Timeline{events: [event | other_events]} = timeline, _name) do
    finished_at = DateTime.utc_now
    duration = DateTime.to_unix(finished_at, :microsecond) - DateTime.to_unix(event.started_at, :microsecond)
    event = %{event | duration: duration}
    %{timeline | events: [event | other_events]}
  end
end

alias ExDebugToolbar.Data.{Collection, Timeline, Timeline.Action}

defimpl Collection, for: Timeline do
  def change(timeline, %Action{action: :start_event, event_name: name}) do
    Timeline.start_event(timeline, name)
  end

  def change(timeline, %Action{action: :finish_event, event_name: name}) do
    Timeline.finish_event(timeline, name)
  end
end
