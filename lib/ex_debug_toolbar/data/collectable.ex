defprotocol ExDebugToolbar.Data.Collectable do
  @doc "returns collection that holds collectable data"
  def init_collection(value)

  @doc "returns encoded value as it will be stored"
  def encode(value)
end
