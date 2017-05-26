defmodule ExDebugToolbar.Poison.Encoder.TupleTest do
  use ExUnit.Case, async: true
  alias Poison.Encoder

  describe "Poison.Encoder protocol" do
    test "tuples are encoded as lists" do
      assert Encoder.encode({:foo, :bar}, []) |> to_string == "[\"foo\",\"bar\"]"
    end
  end
end
