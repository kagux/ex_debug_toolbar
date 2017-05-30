defmodule ExDebugToolbar.Collector.ConnCollector do
  alias ExDebugToolbar.Toolbar

  @behaviour Plug

  def init(opts), do: opts

  def call(%Plug.Conn{} = conn, _opts) do
    Toolbar.add_data(:conn, {:request, conn})
    Plug.Conn.register_before_send(conn, fn conn ->
      Toolbar.add_data(:conn, {:response, conn})
      conn
    end)
  end
end
