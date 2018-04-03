defmodule ExDebugToolbar.ToolbarView do
  @moduledoc false

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

  def ecto_color_class(time) do
    cond do
      time > 50 * @millisecond -> "danger"
      time > 20 * @millisecond -> "warning"
      time > 10 * @millisecond -> "info"
      true -> ""
    end
  end

  def stats_popover_text(stats) do
    ~w(min max total)a
    |> Stream.map(&Map.get(stats, &1))
    |> Stream.map(&native_time_to_string/1)
    |> (&Enum.zip(~w(Fastest Slowest Total), &1)).()
    |> Enum.map(fn {label, value} -> label <> ": " <> value end)
    |> Enum.join("<br>")
  end
end
