alias ExDebugToolbar.Data.Collectable
defimpl Collectable, for: Map do
  def format(map), do: map
end
