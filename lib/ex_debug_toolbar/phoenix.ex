defmodule ExDebugToolbar.Phoenix do
  @moduledoc false

  defmacro __using__(_) do
    if ExDebugToolbar.Config.enabled?(), do: build_plug_ast()
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
      alias ExDebugToolbar.Logger

      defoverridable [call: 2]

      @doc """
      Wrapper around app endpoint. After passing connection through
      toolbar's router we make a decision how to further process it.
      Ignoring request in a toolbar works by not emiting `:ex_debug_toolbar` event
      which creates new request in toolbar. The rest of data collection functions
      become effectively no-op for ignored requests.
      """
      def call(conn, opts) do
        case dispatch_router(conn, opts) do
          # request to Toolbar's internal routes, it's been already
          # processed and we leave it untouched
          %{private: %{phoenix_endpoint: ExDebugToolbar.Endpoint}} = conn ->
            Logger.debug("Request to #{conn.request_path} was processed by internal endpoint")
            conn
          # app request that should be ignored according to configuration,
          # we pass it to app endpoint, but don't register in toolbar
          %{private: %{ex_debug_toolbar_ignore?: true}} = conn ->
            Logger.debug("Request to #{conn.request_path} will be ignored")
            super(conn, opts)
          # otherwise it's an app request we want to register in toolbar and 
          # processed by app's endpoint
          conn ->
            Logger.debug("Request to #{conn.request_path} will be tracked")
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
