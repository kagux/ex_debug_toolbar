defmodule ExDebugToolbar.Data.LogEntry do
  defstruct [
    level: nil,
    message: nil,
    timestamp: nil
  ]
end

alias ExDebugToolbar.Data.{Collectable, LogEntry}

defimpl Collectable, for: LogEntry do
  def format(entry) do
    entry
    |> Map.from_struct
    |> Map.update!(:message, &to_string/1)
    |> Map.update!(:timestamp, fn {date, {h, m, s, _ms}} ->
      {date, {h, m, s}} |> NaiveDateTime.from_erl! |> to_string
    end)
  end
end
