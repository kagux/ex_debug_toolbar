alias ExDebugToolbar.Data.Collectable
defimpl Collectable, for: Ecto.LogEntry do
  @format_keys ~w(decode_time query_time queue_time query)a

  def format(entry) do
    duration = (entry.queue_time || 0) + (entry.query_time || 0) + (entry.decode_time || 0)
    entry
    |> Map.take(@format_keys)
    |> Map.put(:total_time, duration)
  end
end
