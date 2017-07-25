defprotocol ExDebugToolbar.Data.Collection do
  @moduledoc false

  @doc "adds item to collection"
  def add(collection, item)
end
