defmodule ExDebugToolbar.Collector.InstrumentationCollector do
  alias ExDebugToolbar.Toolbar

  def ex_debug_toolbar(:start, _, _) do
    Toolbar.start_request
    Toolbar.start_event("request")
  end
  def ex_debug_toolbar(:stop, time_diff, _) do
    Toolbar.finish_event("request", duration: to_microseconds(time_diff))
  end

  defp to_microseconds(native_time) do
    System.convert_time_unit(native_time, :native, :microsecond)
  end
end
