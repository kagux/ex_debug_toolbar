defmodule ExDebugToolbar.Request.Event do
  defstruct [
    name: nil,
    started_at: nil,
    finished_at: nil,
    duration: 0,
    metadata: %{},
    events: []
  ]
end
