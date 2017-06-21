defmodule ExDebugToolbar.ToolbarView do
  use ExDebugToolbar.Web, :view
  alias ExDebugToolbar.Data.Timeline

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
    {layout_view, layout_template} = conn.assigns.layout
    [
      endpoint: conn.private.phoenix_endpoint,
      controller: get_controller(conn),
      action: conn.private.phoenix_action,
      template: conn.private.phoenix_template,
      view: conn.private.phoenix_view,
      layout_view: layout_view,
      layout_template: layout_template,
    ]
  end

  def rendered_templates(%Timeline{} = timeline) do
    timeline
    |> Timeline.get_all_events
    |> Stream.map(&(&1.name))
    |> Stream.filter(&String.starts_with?(&1, "template#"))
    |> Stream.map(&String.trim_leading(&1, "template#"))
    |> Enum.reduce(%{}, fn name, acc ->
      Map.update acc, name, 1, &(&1 + 1)
    end)
  end

  defp get_controller(%Plug.Conn{private: private}) do
    private.phoenix_controller |> to_string |> String.trim_leading("Elixir.")
  end

  defp conn_with_defaults(conn) do
    ~w(assigns private)a
    |> Enum.reduce(conn, fn key, conn ->
      defaults = Map.get(@default_conn, key)
      Map.update! conn, key, &Map.merge(defaults, &1)
    end)
  end
end
