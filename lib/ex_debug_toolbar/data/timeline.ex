defmodule ExDebugToolbar.Data.Timeline do
  alias ExDebugToolbar.Data.Timeline

  defstruct [
    events: [],
    duration: 0,
    queue: []
  ]

  def duration(%Timeline{} = timeline) do
    timeline.duration
  end

  def start_event(%Timeline{} = timeline, name) do
    event = %Timeline.Event{name: name, started_at: DateTime.utc_now(), events: []}
    %{timeline | queue: [event | timeline.queue]}
  end

  def finish_event(%Timeline{queue: [event], events: events} = timeline, name) do
    closed_event = update_duration(event)
    %{timeline | queue: [], events: [closed_event | events], duration: closed_event.duration + timeline.duration}
  end
  def finish_event(%Timeline{queue: [event | [parent | rest]], events: events} = timeline, name) do
    closed_event = update_duration(event)
    new_parent = %{parent | events: [event | parent.events]}

    %{timeline | queue: [new_parent | rest]}
  end

  defp update_duration(event) do
    finished_at = DateTime.utc_now
    duration = DateTime.to_unix(finished_at, :microsecond) - DateTime.to_unix(event.started_at, :microsecond)
    %{event | duration: duration}
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
