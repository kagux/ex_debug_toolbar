Code.compiler_options(ignore_module_conflict: true)

alias ExDebugToolbar.Config

if Config.enabled?() and Config.debug?() do
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

  # redefine not to raise error
  defimpl Poison.Encoder, for: Ecto.Association.NotLoaded do
    def encode(_assoc, _options), do: "null"
  end

  defimpl Poison.Encoder, for: Regex do
    def encode(regex, _options), do: Regex.source(regex)
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

  defimpl Poison.Encoder, for: Reference do
    defdelegate encode(func, options), to: Encoder, as: :encode_inspect
  end
end

Code.compiler_options(ignore_module_conflict: false)
