alias ExDebugToolbar.Data.Collectable
defimpl Collectable, for: Map do
  def encode(map), do: map
end
