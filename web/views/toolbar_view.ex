defmodule ExDebugToolbar.ToolbarView do
  use ExDebugToolbar.Web, :view

  def format_native_time(time) do
    time
    |> System.convert_time_unit(:native, :micro_seconds)
    |> time_to_string
  end

  defp time_to_string(time) when time >= 1000, do: [time |> div(1000) |> Integer.to_string, "ms"]
  defp time_to_string(time), do: [Integer.to_string(time), "µs"]

  def log_entry_color_class(%{level: level}) do
    case level do
      :debug -> "text-muted"
      :error -> "danger"
      :info -> "info"
      :warn -> "warning"
      _ -> ""
    end
  end

  def ecto_query_color_class(%{total_time: time}) do
    cond do
      time > System.convert_time_unit(50, :millisecond, :native) -> "danger"
      time > System.convert_time_unit(20, :millisecond, :native) -> "warning"
      time > System.convert_time_unit(10, :millisecond, :native) -> "info"
      true -> ""
    end
  end
end
