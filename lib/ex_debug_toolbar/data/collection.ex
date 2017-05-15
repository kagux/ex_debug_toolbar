defprotocol ExDebugToolbar.Data.Collection do
  @doc "applies changes to collection"
  def change(collection, changes)
end

alias ExDebugToolbar.Data.Collection

defimpl Collection, for: Map do
  def change(collection, map), do: Map.merge(collection, map)
end
