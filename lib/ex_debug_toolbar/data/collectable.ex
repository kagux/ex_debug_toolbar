defprotocol ExDebugToolbar.Data.Collectable do
  @doc "returns encoded value as it will be stored"
  def encode(value)
end
