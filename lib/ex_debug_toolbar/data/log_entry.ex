defmodule ExDebugToolbar.Data.LogEntry do
  defstruct [
    level: nil,
    message: nil,
    timestamp: nil,
    metadata: []
  ]
end

alias ExDebugToolbar.Data.{Collectable, LogEntry}

defimpl Collectable, for: LogEntry do
  def init_collection(_), do: []
end

defimpl Poison.Encoder, for: LogEntry do
  def encode(entry, _options) do
    %{
      level: entry.level,
      message: inspect(entry.message),
      metadata: inspect(entry.metadata),
      timestamp: inspect(entry.timestamp)
    }
    |> Poison.encode!
  end
end
