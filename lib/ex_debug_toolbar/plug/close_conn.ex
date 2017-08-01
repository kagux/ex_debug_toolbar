defmodule ExDebugToolbar.Plug.CloseConn do
  @moduledoc false

  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    conn |> put_resp_header("connection", "close")
  end
end
