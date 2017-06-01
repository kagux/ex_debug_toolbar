defmodule ExDebugToolbar.ToolbarView do
  use ExDebugToolbar.Web, :view

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
