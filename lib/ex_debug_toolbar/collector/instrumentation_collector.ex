defmodule ExDebugToolbar.Collector.InstrumentationCollector do
  alias ExDebugToolbar.Toolbar

  def ex_debug_toolbar(:start, _, _) do
    Toolbar.start_request
    Toolbar.start_event("request")
  end
  def ex_debug_toolbar(:stop, _, _) do
    Toolbar.finish_event("request")
  end
end
