defmodule ExDebugToolbar.Poison.EncoderTest do
  use ExUnit.Case, async: true
  alias Poison.Encoder

  test "tuple is encoded as lists" do
    assert encode({:foo, :bar}) == ~S(["foo","bar"])
  end

  test "not loaded ecto association is encoded as null" do
    assert encode(%Ecto.Association.NotLoaded{}) == "null"
  end

  test "PID encoding" do
    assert self() |> encode |> is_bitstring
  end

  test "function encoding" do
    assert fn -> :ok end |> encode |> is_bitstring
  end

  test "regexp encoding" do
    assert ~r/\d/ |> encode == "\\d"
  end

  defp encode(value) do
    value |> Encoder.encode([]) |> to_string
  end
end
