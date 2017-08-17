defmodule ExDebugToolbar.Collector.InstrumentationCollector do
  @moduledoc false

  require Logger

  def ex_debug_toolbar(:start, _, %{conn: conn}) do
    conn.private.request_id |> ExDebugToolbar.start_request
  end
  def ex_debug_toolbar(:stop, _, _) do
    start = System.monotonic_time
    ExDebugToolbar.stop_request(self())
    finish = System.monotonic_time
    diff = System.convert_time_unit(finish - start, :native, :millisecond)
    Logger.debug "Waited #{inspect(diff)} for request ID=#{inspect(self())} to stop"
    ExDebugToolbar.ToolbarChannel.broadcast_request
  end

  def phoenix_controller_call(:start, _, _) do
    ExDebugToolbar.start_event("controller.call")
  end
  def phoenix_controller_call(:stop, time_diff, _) do
    ExDebugToolbar.finish_event("controller.call", duration: time_diff)
  end

  def phoenix_controller_render(:start, _, _) do
    ExDebugToolbar.start_event("controller.render")
  end
  def phoenix_controller_render(:stop, time_diff, _) do
    ExDebugToolbar.finish_event("controller.render", duration: time_diff)
  end
end
