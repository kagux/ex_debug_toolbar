defprotocol ExDebugToolbar.Data.Collectable do
  @doc "returns formated value as it will be stored"
  def format(value)
end
