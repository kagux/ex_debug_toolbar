defmodule ExDebugToolbar.Data.Timeline.Event do
  defstruct [
    name: nil,
    started_at: nil,
    duration: 0,
    events: [],
  ]
end
