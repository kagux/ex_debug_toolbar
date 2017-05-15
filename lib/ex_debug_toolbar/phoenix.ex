defmodule ExDebugToolbar.Phoenix do
  defmacro __using__(_) do
    quote do
      require Phoenix.Endpoint
      alias Phoenix.Endpoint

      Logger.add_backend(ExDebugToolbar.Collector.LoggerCollector)

      Endpoint.socket "/__ex_debug_toolbar__/socket", ExDebugToolbar.UserSocket
      Endpoint.plug ExDebugToolbar.Plug.Request
      Endpoint.plug ExDebugToolbar.Plug.CodeInjector
    end
  end
end
