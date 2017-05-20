alias ExDebugToolbar.Data.Collectable
defimpl Collectable, for: Ecto.LogEntry do
  def init_collection(_log_entry), do: []
end
