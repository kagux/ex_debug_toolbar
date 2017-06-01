defmodule ExDebugToolbar.View.Helpers.TimeHelpersTest do
  use ExUnit.Case, async: true
  alias ExDebugToolbar.View.Helpers.TimeHelpers

  @microsecond System.convert_time_unit(1, :micro_seconds, :native)

  describe "native_time_to_string/1" do
    test "microseconds" do
      assert TimeHelpers.native_time_to_string(10 * @microsecond) == "10µs"
      assert TimeHelpers.native_time_to_string(999 * @microsecond) == "999µs"
    end

    test "milliseconds" do
      assert TimeHelpers.native_time_to_string(1000 * @microsecond) == "1ms"
      assert TimeHelpers.native_time_to_string(5499 * @microsecond) == "5ms"
      assert TimeHelpers.native_time_to_string(5500 * @microsecond) == "6ms"
    end
  end
end
