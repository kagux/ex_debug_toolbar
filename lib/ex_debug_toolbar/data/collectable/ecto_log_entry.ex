alias ExDebugToolbar.Data.Collectable
defimpl Collectable, for: Ecto.LogEntry do
  @encode_keys ~w(decode_time query_time queue_time query)a

  def init_collection(_entry), do: []

  def encode(entry) do
    Map.take(entry, @encode_keys)
  end
end
