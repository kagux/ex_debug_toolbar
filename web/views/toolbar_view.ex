defmodule ExDebugToolbar.ToolbarView do
  @moduledoc false

  use ExDebugToolbar.Web, :view
  alias ExDebugToolbar.Data.Timeline
  alias ExDebugToolbar.{Breakpoint, Request}

  @millisecond System.convert_time_unit(1, :millisecond, :native)

  @default_conn %{
    assigns: %{
      layout: {"none", "none"}
    },
    private: %{
      phoenix_controller: "none",
      phoenix_endpoint: "none",
      phoenix_action: "none",
      phoenix_view: "none",
      phoenix_template: "none"
    }
  }

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

  def controller_action(%Plug.Conn{} = conn) do
    conn = conn_with_defaults(conn)
    "#{get_controller(conn)} :: #{conn.private.phoenix_action}"
  end

  def conn_details(%Plug.Conn{} = conn) do
    conn = conn_with_defaults(conn)
    {layout_view, layout_template} = case conn.assigns.layout do
      false -> @default_conn.assigns.layout
      layout -> layout
    end
    [
      "Endpoint": conn.private.phoenix_endpoint,
      "Controller": get_controller(conn),
      "Action": conn.private.phoenix_action,
      "Template": conn.private.phoenix_template,
      "View": conn.private.phoenix_view,
      "Layout View": layout_view,
      "Layout Template": layout_template,
    ]
  end

  def rendered_templates(%Timeline{} = timeline) do
    timeline
    |> Timeline.get_all_events
    |> Stream.filter(&String.starts_with?(&1.name, "template#"))
    |> Enum.reduce(%{}, fn event, acc ->
      Map.update(
        acc,
        event.name,
        %{count: 1, durations: [event.duration], min: 0, max: 0, avg: 0, total: 0},
        &(%{&1 | count: &1.count + 1, durations: [event.duration | &1.durations]})
      )
    end)
    |> Stream.map(fn {name, stats} ->
      {name, %{stats |
        min: Enum.min(stats.durations),
        max: Enum.max(stats.durations),
        total: Enum.sum(stats.durations),
        avg: div(Enum.sum(stats.durations), Enum.count(stats.durations))
      }}
    end)
    |> Stream.map(fn {name, stats} -> {String.trim_leading(name, "template#"), stats} end)
    |> Enum.sort_by(fn {_, stats} -> -stats.total end)
  end

  def stats_popover_text(stats) do
    ~w(min max total)a
    |> Stream.map(&Map.get(stats, &1))
    |> Stream.map(&native_time_to_string/1)
    |> (&Enum.zip(~w(Fastest Slowest Total), &1)).()
    |> Enum.map(fn {label, value} -> label <> ": " <> value end)
    |> Enum.join("<br>")
  end

  def controller_times(%Timeline{} = timeline) do
    event_names = MapSet.new ~w(controller.call controller.render)
    events = timeline
    |> Timeline.get_all_events
    |> Enum.filter(&MapSet.member?(event_names, &1.name))
    {call, render} = case events do
      [call, render] -> {call, render}
      [call] -> {call, %Timeline.Event{}}
    end
    [
      "Controller": call.duration - render.duration,
      "Templates": render.duration,
    ]
  end

  def ecto_inline_queries(queries) do
    queries |> Enum.filter(fn {_, _, type} -> type == :inline end)
  end

  def ecto_parallel_queries(queries) do
    queries |> Enum.filter(fn {_, _, type} -> type == :parallel end)
  end

  def count_current_request_breakpoints(%Request{pid: pid}, breakpoints) do
    breakpoints |> Enum.filter(&(&1.pid == pid)) |> Enum.count
  end

  def breakpoint_code_snippet_start_line(%Breakpoint{code_snippet: code_snippet}) do
    code_snippet |> hd |> Tuple.to_list |> List.last
  end

  def breakpoint_sorted_binding(%Breakpoint{binding: binding}) do
    binding |> Keyword.keys |> Enum.sort
  end

  def breakpoint_relative_line(%Breakpoint{code_snippet: code_snippet, line: line}) do
    code_snippet
    |> Enum.find_index(fn {_, n} -> n == line end)
    |> Kernel.+(1)
  end

  def breakpoint_color_class(%Breakpoint{pid: pid}, %Request{pid: pid}), do: "bg-success"
  def breakpoint_color_class(_, _), do: ""

  defp get_controller(%Plug.Conn{private: private}) do
    private.phoenix_controller |> to_string |> String.trim_leading("Elixir.")
  end

  defp conn_with_defaults(conn) do
    ~w(assigns private)a
    |> Enum.reduce(conn, fn key, conn ->
      defaults = Map.get(@default_conn, key)
      Map.update! conn, key, &Map.merge(defaults, &1 || %{})
    end)
  end
end
