defmodule ExDebugToolbar.Request.LogEntry do
  defstruct [
    level: nil,
    message: nil,
    timestamp: nil,
    metadata: []
  ]
end
