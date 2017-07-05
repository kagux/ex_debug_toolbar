defmodule ExDebugToolbar.Collector.InstrumentationCollector do
  alias ExDebugToolbar.Toolbar

  def ex_debug_toolbar(:start, _, %{conn: conn}) do
    conn.private.request_id |> Toolbar.start_request
  end
  def ex_debug_toolbar(:stop, _, _) do
    Toolbar.stop_request(self())
    ExDebugToolbar.ToolbarChannel.broadcast_request
  end

  def phoenix_controller_call(:start, _, _) do
    Toolbar.start_event("controller.call")
  end
  def phoenix_controller_call(:stop, time_diff, _) do
    Toolbar.finish_event("controller.call", duration: time_diff)
  end

  def phoenix_controller_render(:start, _, _) do
    Toolbar.start_event("controller.render")
  end
  def phoenix_controller_render(:stop, time_diff, _) do
    Toolbar.finish_event("controller.render", duration: time_diff)
  end
end
