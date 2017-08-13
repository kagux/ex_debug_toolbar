defmodule ExDebugToolbar.Fixtures.Endpoint do
  use Phoenix.Endpoint, otp_app: :ex_debug_toolbar
  use ExDebugToolbar.Phoenix
  require Logger
  import Plug.Conn

  plug Plug.RequestId


  plug :tracked_plug

  def tracked_plug(conn, _) do
    ExDebugToolbar.record_event "test_request", fn ->
      Logger.debug "log entry"
      if timeout = conn.assigns[:timeout], do: :timer.sleep timeout
      conn
      |> Plug.Conn.assign(:called?, true)
      |> send_response
    end
  end

  defp send_response(%{assigns: %{error: :no_route}} = conn) do
    raise Phoenix.Router.NoRouteError, conn: conn, router: __MODULE__
  end

  defp send_response(%{assigns: %{error: :exception}}) do
    raise RuntimeError, "just some runtime error"
  end

  defp send_response(conn) do
    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, "<html><body></body></html>")
  end
end
