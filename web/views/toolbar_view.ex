defmodule ExDebugToolbar.ToolbarView do
  use ExDebugToolbar.Web, :view
  @millisecond System.convert_time_unit(1, :millisecond, :native)

  def log_color_class(%{level: level}) do
    case level do
      :debug -> "text-muted"
      :error -> "danger"
      :info -> "info"
      :warn -> "warning"
      _ -> ""
    end
  end

  def log_timestamp_to_string({date, {h, m, s, _ms}}) do
    {date, {h, m, s}} |> NaiveDateTime.from_erl! |> to_string
  end

  def ecto_color_class(%Ecto.LogEntry{} = query) do
    case query_total_time(query) do
      time when time > 50 * @millisecond -> "danger"
      time when time > 20 * @millisecond -> "warning"
      time when time > 10 * @millisecond -> "info"
      _ -> ""
    end
  end

  def query_total_time(%Ecto.LogEntry{} = query) do
    (query.decode_time || 0) + (query.queue_time || 0) + (query.query_time || 0)
  end
end
