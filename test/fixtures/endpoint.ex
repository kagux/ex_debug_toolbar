defmodule ExDebugToolbar.Fixtures.Endpoint do
  use Phoenix.Endpoint, otp_app: :ex_debug_toolbar
  use ExDebugToolbar.Phoenix
  require Logger
  import Plug.Conn
  alias ExDebugToolbar.Toolbar

  plug Plug.RequestId


  plug :tracked_plug

  def tracked_plug(conn, _) do
    Toolbar.record_event "test_request", fn ->
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
end
