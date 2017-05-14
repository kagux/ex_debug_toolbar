defprotocol ExDebugToolbar.Data.Collectable do
  @doc "returns container that holds collectable data"
  def init_container(value)
  @doc "adds new value to container"
  def put(value, container)
end

alias ExDebugToolbar.Data.Collectable

defimpl Collectable, for: Map do
  def init_container(_map), do: %{}
  def put(map, container), do: Map.merge(container, map)
end
