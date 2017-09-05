defmodule ExDebugToolbar.Phoenix do
  @moduledoc false

  defmacro __using__(_) do
    if Application.get_env(:ex_debug_toolbar, :enable), do: build_plug_ast()
  end

  def build_plug_ast do
    quote location: :keep do
      require Phoenix.Endpoint
      alias Phoenix.Endpoint
      alias ExDebugToolbar.Plug.Router

      Logger.add_backend(ExDebugToolbar.Collector.LoggerCollector)

      Endpoint.socket "/__ex_debug_toolbar__/socket", ExDebugToolbar.UserSocket

      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_) do
    quote location: :keep do
      require Phoenix.Endpoint
      alias Phoenix.Endpoint
      alias ExDebugToolbar.Plug.Router

      defoverridable [call: 2]
      def call(conn, opts) do
        case dispatch_router(conn, opts) do
          %{private: %{phoenix_endpoint: ExDebugToolbar.Endpoint}} = conn ->
            conn
          %{private: %{toolbar_ignore_path?: true}} = conn ->
            super(conn, opts)
          conn ->
          Endpoint.instrument(__MODULE__, :ex_debug_toolbar, %{conn: conn}, fn ->
            super(conn, opts)
          end)
        end
      end

      defp dispatch_router(conn, opts) do
        opts = Router.init(opts)
        Router.call(conn, opts)
      end
    end
  end
end
