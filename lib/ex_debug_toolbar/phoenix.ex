if Application.get_env(:ex_debug_toolbar, :enable, false) do
  defmodule ExDebugToolbar.Phoenix do
    defmacro __using__(_) do
      quote do
        require Phoenix.Endpoint
        alias Phoenix.Endpoint
        alias ExDebugToolbar.Plug.Router

        Logger.add_backend(ExDebugToolbar.Collector.LoggerCollector)

        Endpoint.socket "/__ex_debug_toolbar__/socket", ExDebugToolbar.UserSocket

        def call(conn, opts) do
          case dispatch_router(conn, opts) do
            %{private: %{phoenix_endpoint: ExDebugToolbar.Endpoint}} = conn ->
              conn
            conn ->
            Endpoint.instrument(conn, :ex_debug_toolbar, %{conn: conn}, fn ->
              super(conn, opts)
            end)
          end
        end
        defoverridable [call: 2]

        defp dispatch_router(conn, opts) do
          opts = Router.init(opts)
          Router.call(conn, opts)
        end
      end
    end
  end
else
  defmodule ExDebugToolbar.Phoenix do
    defmacro __using__(_), do: :ok
  end
end
