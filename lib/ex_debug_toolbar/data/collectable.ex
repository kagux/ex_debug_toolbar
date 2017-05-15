defprotocol ExDebugToolbar.Data.Collectable do
  @doc "returns collection that holds collectable data"
  def init_collection(value)
end

alias ExDebugToolbar.Data.Collectable

defimpl Collectable, for: Map do
  def init_collection(_map), do: %{}
end
