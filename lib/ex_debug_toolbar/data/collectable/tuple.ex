alias ExDebugToolbar.Data.Collectable
defimpl Collectable, for: Tuple do
  def format(tuple), do: tuple
end
