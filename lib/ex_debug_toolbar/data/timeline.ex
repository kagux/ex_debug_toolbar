defmodule ExDebugToolbar.Data.Timeline do
  alias ExDebugToolbar.Data.{Event, Timeline}

  defstruct [
    events: []
  ]

  def duration(%Timeline{} = timeline) do
    timeline.events
    |> Stream.map(&(&1.duration))
    |> Stream.reject(&is_nil/1)
    |> Enum.sum
  end

  def upsert_event(%Timeline{} = timeline, %Event{} = event) do
    case {timeline.events, event.name} do
      {[], _} -> insert_event(timeline, event)
      {[%{name: name} | _], other} when name != other -> insert_event(timeline, event)
      {[%{started_at: time, name: name}], name} when not is_nil(time) -> update_last_event(timeline)
    end
  end

  defp update_last_event(%{events: [event | other_events]} = timeline) do
    finished_at = DateTime.utc_now
    duration = DateTime.to_unix(finished_at, :microsecond) - DateTime.to_unix(event.started_at, :microsecond)
    event = %{event | duration: duration}
    %{timeline | events: [event | other_events]}
  end
  
  defp insert_event(timeline, event) do
    event = %{event | started_at: DateTime.utc_now()}
    %{timeline | events: [event | timeline.events]}
  end
end

