defprotocol ExDebugToolbar.Data.Collection do
  @doc "adds item to collection"
  def add(collection, item)

  @doc "formats item"
  def format_item(collection, item)
end
