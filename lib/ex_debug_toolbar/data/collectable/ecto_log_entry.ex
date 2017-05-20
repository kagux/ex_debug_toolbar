alias ExDebugToolbar.Data.Collectable
defimpl Collectable, for: Ecto.LogEntry do
  @encode_keys ~w(decode_time query_time queue_time query)a

  def init_collection(_entry), do: []

  def encode(entry) do
    duration = (entry.queue_time || 0) + (entry.query_time || 0) + (entry.decode_time || 0)
    entry
    |> Map.take(@encode_keys)
    |> Map.put(:total_time, duration)
  end
end
