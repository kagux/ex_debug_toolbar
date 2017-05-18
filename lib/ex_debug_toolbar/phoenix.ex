defmodule ExDebugToolbar.Phoenix do
  defmacro __using__(_) do
    quote do
      require Phoenix.Endpoint
      alias Phoenix.Endpoint
      alias ExDebugToolbar.Plug.RequestId

      Logger.add_backend(ExDebugToolbar.Collector.LoggerCollector)

      Endpoint.socket "/__ex_debug_toolbar__/socket", ExDebugToolbar.UserSocket

      Endpoint.plug ExDebugToolbar.Plug.CodeInjector

      def call(conn, opts) do
        conn = call_request_id_plugs(conn, opts)
        Endpoint.instrument(conn, :ex_debug_toolbar, fn ->
          super(conn, opts)
        end)
      end
      defoverridable [call: 2]

      defp call_request_id_plugs(conn, opts) do
        opts = RequestId.init(opts)
        ExDebugToolbar.Plug.RequestId.call(conn, opts)
      end
    end
  end
end
