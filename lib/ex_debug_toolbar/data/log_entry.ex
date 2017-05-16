defmodule ExDebugToolbar.Data.LogEntry do
  defstruct [
    level: nil,
    message: nil,
    timestamp: nil
  ]
end

alias ExDebugToolbar.Data.{Collectable, LogEntry}

defimpl Collectable, for: LogEntry do
  def init_collection(_), do: []
end
