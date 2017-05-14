defmodule ExDebugToolbar.Data.Event do
  alias ExDebugToolbar.Data.Timeline

  defstruct [
    name: nil,
    started_at: nil,
    duration: nil
  ]
end

alias ExDebugToolbar.Data.{Collectable, Event, Timeline}

defimpl Collectable, for: Event do
  def init_container(_event), do: %Timeline{}
  def put(event, timeline), do: Timeline.upsert_event timeline, event
end
