defmodule ExDebugToolbar.Phoenix do
  defmacro __using__(_) do
    quote do
      require Phoenix.Endpoint
      alias Phoenix.Endpoint
      alias ExDebugToolbar.Plug.Pipeline

      Logger.add_backend(ExDebugToolbar.Collector.LoggerCollector)

      Endpoint.socket "/__ex_debug_toolbar__/socket", ExDebugToolbar.UserSocket

      Endpoint.plug ExDebugToolbar.Plug.Pipeline

      def call(conn, opts) do
        Endpoint.instrument(conn, :ex_debug_toolbar, fn ->
          super(conn, opts)
        end)
      end

      defoverridable [call: 2]
    end
  end
end
