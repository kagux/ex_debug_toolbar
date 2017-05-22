alias ExDebugToolbar.Data.Collectable
defimpl Collectable, for: Tuple do
  def encode(tuple), do: tuple
end
