defmodule EndpointUsingExDebugToolbar do
  use Phoenix.Endpoint, otp_app: :ex_debug_toolbar
  import Plug.Conn

  plug Plug.RequestId

  use ExDebugToolbar.Phoenix

  plug :dummy_plug
  def dummy_plug(conn, _) do
    if timeout = conn.assigns[:timeout] do
      :timer.sleep timeout
    end
    conn
    |> Plug.Conn.assign(:called?, true)
    |> put_resp_content_type("text/html")
    |> send_resp(200, "<html><body></body></html>")
  end
end

defmodule ExDebugToolbar.PhoenixTest do
  use ExUnit.Case, async: true
  use Plug.Test
  import Supervisor.Spec

  setup_all do
    children = [supervisor(EndpointUsingExDebugToolbar, [])]
    opts = [strategy: :one_for_one, name: ExDebugToolbarTest.Supervisor]
    Supervisor.start_link(children, opts)
    :ok
  end

  test "it works" do
    assert {200, _, _} = sent_resp(make_request())
  end

  test "it executes existing plugs" do
    assert make_request().assigns[:called?] == true
  end

  defp make_request(assigns \\ %{}) do
    conn(:get, "/")
    |> Map.put(:assigns, Map.new(assigns))
    |> EndpointUsingExDebugToolbar.call(%{})
  end
end
