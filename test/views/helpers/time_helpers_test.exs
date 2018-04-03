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

    test "return N/A for nil value" do
      assert TimeHelpers.native_time_to_string(nil) == "N/A"
    end
  end

  describe "datetime_to_string/1" do
    test "rounds naive datetime up to seconds" do
      {:ok, datetime} = NaiveDateTime.new(2017, 3, 15, 14, 15, 20, {1, 1})
      assert TimeHelpers.datetime_to_string(datetime) == "2017-03-15 14:15:20"
    end
  end
end
