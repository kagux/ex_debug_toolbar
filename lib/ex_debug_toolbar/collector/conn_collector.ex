defmodule ExDebugToolbar.Collector.ConnCollector do
  @moduledoc false

  @behaviour Plug

  def init(opts), do: opts

  def call(%Plug.Conn{} = conn, _opts) do
    Plug.Conn.register_before_send(conn, fn conn ->
      ExDebugToolbar.add_data(:conn, conn)
      conn
    end)
  end
end
