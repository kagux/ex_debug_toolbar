defmodule ExDebugToolbar.Data.EctoQueries do
  defstruct [queries: []]
end

alias ExDebugToolbar.Data.{Collection, EctoQueries}

defimpl Collection, for: EctoQueries do
  @format_keys ~w(decode_time query_time queue_time query)a

  def add(collection, entry) when is_map(entry) do
    Map.update!(collection, :queries, &([entry | &1]))
  end

  def format_item(_collection, %Ecto.LogEntry{} = entry) do
    duration = (entry.queue_time || 0) + (entry.query_time || 0) + (entry.decode_time || 0)
    entry
    |> Map.take(@format_keys)
    |> Map.put(:total_time, duration)
  end
end
