alias ExDebugToolbar.Data.Collection
defimpl Collection, for: Map do
  def format_item(_map, item) when is_map(item), do: item

  def add(collection, item) when is_map(item) do
    Map.merge(collection, item)
  end
end
