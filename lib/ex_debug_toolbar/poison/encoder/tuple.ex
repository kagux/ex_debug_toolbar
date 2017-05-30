defimpl Poison.Encoder, for: Tuple do
  def encode(tuple, options) do
    tuple |> Tuple.to_list |> Poison.Encoder.encode(options)
  end
end
