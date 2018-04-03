defmodule ExDebugToolbar.View.Helpers.TimeHelpers do
  @moduledoc false

  def native_time_to_string(nil), do: "N/A"
  def native_time_to_string(native_time) do
    native_time
    |> System.convert_time_unit(:native, :micro_seconds)
    |> microseconds_to_string
  end

  def datetime_to_string(%NaiveDateTime{} = datetime) do
    datetime |> Map.put(:microsecond, {0, 0}) |> NaiveDateTime.to_string
  end

  defp microseconds_to_string(time) when time >= 1000, do: round(time / 1000) |> format_time("ms")
  defp microseconds_to_string(time), do: format_time(time, "µs")

  defp format_time(time, unit), do: Integer.to_string(time) <> unit
end
