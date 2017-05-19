defmodule ExDebugToolbar.Collector.InstrumentationCollector do
  alias ExDebugToolbar.Toolbar

  def ex_debug_toolbar(:start, _, _) do
    Toolbar.start_request
    Toolbar.start_event("request")
  end
  def ex_debug_toolbar(:stop, time_diff, _) do
    Toolbar.finish_event("request", duration: time_diff)
  end

  def phoenix_controller_call(:start, _, %{conn: conn}) do
    event_name = controller_event_name(conn)
    Toolbar.start_event(event_name)
    event_name
  end
 
  def phoenix_controller_call(:stop, _diff, event_name) do
    Toolbar.finish_event(event_name)
  end
 
  def phoenix_controller_render(:start, _, %{template: template}) do
    Toolbar.start_event(template)
    template
  end
 
  def phoenix_controller_render(:stop, _diff, template) do
    Toolbar.finish_event(template)
  end

  defp controller_event_name(%{private: %{phoenix_controller: controller, phoenix_action: action}}) do
    module_name = controller |> to_string |> String.trim_leading("Elixir.")
    "#{module_name}:#{to_string(action)}"
  end
  defp controller_event_name(_) do
    "UnknownController"
  end
end
