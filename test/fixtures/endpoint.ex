defmodule ExDebugToolbar.Fixtures.Endpoint do
  use Phoenix.Endpoint, otp_app: :ex_debug_toolbar
  require Logger
  import Plug.Conn

  plug Plug.RequestId

  use ExDebugToolbar.Phoenix

  plug :dummy_plug
  def dummy_plug(conn, _) do
    Logger.debug "log entry"
    conn = conn
    |> Plug.Conn.assign(:called?, true)
    |> put_resp_content_type("text/html")
    |> send_resp(200, "<html><body></body></html>")
    if timeout = conn.assigns[:timeout] do
      :timer.sleep timeout
    end
    conn
  end
end
