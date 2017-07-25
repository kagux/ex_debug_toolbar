defmodule ExDebugToolbar.Collector.ConnCollector do
  @behaviour Plug

  def init(opts), do: opts

  def call(%Plug.Conn{} = conn, _opts) do
    ExDebugToolbar.add_data(:conn, {:request, conn})
    Plug.Conn.register_before_send(conn, fn conn ->
      ExDebugToolbar.add_data(:conn, {:response, conn})
      conn
    end)
  end
end
