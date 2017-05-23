defmodule ExDebugToolbar.Data.Logs do
  defstruct [entries: []]
end

alias ExDebugToolbar.Data.{Collection, Logs, LogEntry}

defimpl Collection, for: Logs do
  def add(collection, entry) when is_map(entry) do
    Map.update!(collection, :entries, &([entry | &1]))
  end

  def format_item(_collection, %LogEntry{} = entry) do
    entry
    |> Map.from_struct
    |> Map.update!(:message, &to_string/1)
    |> Map.update!(:timestamp, fn {date, {h, m, s, _ms}} ->
      {date, {h, m, s}} |> NaiveDateTime.from_erl! |> to_string
    end)
  end
end
