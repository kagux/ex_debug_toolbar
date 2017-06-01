defmodule ExDebugToolbar.Poison.Encoder do
  def encode_inspect(term, options) do
    term |> inspect |> Poison.Encoder.encode(options)
  end
end

alias ExDebugToolbar.Poison.Encoder

defimpl Poison.Encoder, for: Tuple do
  def encode(tuple, options) do
    tuple |> Tuple.to_list |> Poison.Encoder.encode(options)
  end
end

defimpl Poison.Encoder, for: Ecto.Association.NotLoaded do
  def encode(_assoc, _options) do
    "null"
  end
end

defimpl Poison.Encoder, for: Port do
  defdelegate encode(port, options), to: Encoder, as: :encode_inspect
end

defimpl Poison.Encoder, for: PID do
  defdelegate encode(pid, options), to: Encoder, as: :encode_inspect
end

defimpl Poison.Encoder, for: Function do
  defdelegate encode(func, options), to: Encoder, as: :encode_inspect
end
