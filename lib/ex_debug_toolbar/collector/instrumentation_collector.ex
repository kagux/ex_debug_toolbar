defmodule ExDebugToolbar.Collector.InstrumentationCollector do
  alias ExDebugToolbar.Toolbar

  def ex_debug_toolbar(:start, _, %{conn: conn}) do
    conn.private.request_id |> Toolbar.start_request
  end
  def ex_debug_toolbar(:stop, _, _), do: :ok

  def phoenix_controller_call(:start, _, %{conn: conn}) do
    event_name = controller_event_name(conn)
    Toolbar.start_event(event_name)
    event_name
  end
  def phoenix_controller_call(:stop, time_diff, event_name) do
    Toolbar.finish_event(event_name, duration: time_diff)
  end

  def phoenix_controller_render(:start, _, %{template: template}) do
    Toolbar.start_event(template)
    template
  end
  def phoenix_controller_render(:stop, time_diff, template) do
    Toolbar.finish_event(template, duration: time_diff)
  end

  defp controller_event_name(%{private: %{phoenix_controller: controller, phoenix_action: action}}) do
    module_name = controller |> to_string |> String.trim_leading("Elixir.")
    "#{module_name}:#{to_string(action)}"
  end
  defp controller_event_name(_) do
    "UnknownController"
  end
end
