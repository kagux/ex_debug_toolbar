defmodule ExDebugToolbar.Plug.Pipeline do
  @moduledoc false

  use Plug.Builder

  plug ExDebugToolbar.Plug.RequestId
  plug ExDebugToolbar.Plug.CodeInjector
  plug ExDebugToolbar.Collector.ConnCollector
end
