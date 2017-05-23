alias ExDebugToolbar.Data.Collection

defimpl Collection, for: List do
  def add(collection, item) do 
    [item | collection]
  end

  def format_item(_list, item), do: item
end
