defmodule ExDebugToolbar.Test.Support.Data.TimelineHelpers do
  alias ExDebugToolbar.Data.Timeline

  def find_event(%Timeline{} = timeline, event_name), do: timeline.events |> find_event(event_name)
  def find_event([%{name: event_name} = event | _], event_name), do: event
  def find_event([event | events], event_name) do
    find_event(event.events, event_name) || find_event(events, event_name)
  end
  def find_event(_, _), do: false
end
