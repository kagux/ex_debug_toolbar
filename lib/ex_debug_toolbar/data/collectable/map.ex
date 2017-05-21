alias ExDebugToolbar.Data.Collectable
defimpl Collectable, for: Map do
  def init_collection(_map), do: %{}

  def encode(map), do: map
end
