defmodule EndpointUsingExDebugToolbar do
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

defmodule ExDebugToolbar.PhoenixTest do
  use ExUnit.Case, async: true
  use Plug.Test
  import Supervisor.Spec
  import ExDebugToolbar.Test.Support.RequestHelpers
  alias ExDebugToolbar.Data.Timeline

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

  test "it tracks execution time of all following plugs in pipeline" do
    make_request timeout: 100
    assert {:ok, request} = get_request()
    assert Timeline.duration(request.data.timeline) > 90 * 1000 # not sure why
  end

  defp make_request(assigns \\ %{}) do
    conn(:get, "/")
    |> Map.put(:assigns, Map.new(assigns))
    |> EndpointUsingExDebugToolbar.call(%{})
  end
end
