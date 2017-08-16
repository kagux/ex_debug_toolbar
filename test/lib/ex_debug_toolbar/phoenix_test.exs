defmodule ExDebugToolbar.PhoenixTest do
  use ExUnit.Case, async: true
  use Plug.Test
  import Phoenix.ConnTest, only: [assert_error_sent: 2]
  import Supervisor.Spec
  import ExDebugToolbar.Test.Support.RequestHelpers
  alias ExDebugToolbar.Fixtures.Endpoint

  setup_all do
    children = [supervisor(Endpoint, [])]
    opts = [strategy: :one_for_one, name: ExDebugToolbarTest.Supervisor]
    Supervisor.start_link(children, opts)
    :ok
  end

  test "it works" do
    conn = make_request("/")
    assert {200, _, _} = sent_resp(conn)
  end

  test "it executes existing plugs" do
    conn = make_request("/")
    assert conn.assigns[:called?] == true
  end

  test "it tracks execution time of all following plugs in pipeline" do
    make_request "/", timeout: 100
    assert {:ok, request} = get_request()
    assert request.timeline.duration > 70 * 1000 # not sure why
  end

  test "it creates request and injects toolbar on 404 errors" do
    conn = make_request "/", error: :no_route
    assert {:ok, request} = get_request()
    assert request.stopped?
    assert {404, _, body} = sent_resp(conn)
    # cannot use simple String.contains/2 as it appears in code snippet and matches
    assert Regex.match? ~r/src=['"].*?toolbar.js['"]/, body
  end

  test "it creates request and injects toolbar on 500 errors" do
    {_, _, body} = assert_error_sent 500, fn ->
      make_request "/", error: :exception
    end
    assert {:ok, request} = get_request()
    assert request.stopped?
    # cannot use simple String.contains/2 as it appears in code snippet and matches
    assert Regex.match? ~r/src=['"].*?toolbar.js['"]/, body
  end

  test "it closes connection" do
    conn = make_request("/")
    assert Plug.Conn.get_resp_header(conn, "connection") == ["close"]
  end

  test "it removes glob params from connection" do
    conn = make_request("/")
    refute Map.has_key? conn.params, "glob"
    refute Map.has_key? conn.path_params, "glob"
  end

  describe "requests to __ex_debug_toolbar__" do
    setup do
      conn = make_request("/__ex_debug_toolbar__/js/toolbar.js")
      {:ok, conn: conn}
    end

    test "are not tracked" do
      assert {:error, :not_found} = get_request()
    end

    test "routed through ExDebugToolbar.Endpoint", context do
      assert %{phoenix_endpoint: ExDebugToolbar.Endpoint} = context.conn.private
    end
  end

  defp make_request(path, assigns \\ %{}) do
    conn(:get, path)
    |> put_req_header("accept", "text/html")
    |> Map.put(:assigns, Map.new(assigns))
    |> Endpoint.call(%{})
  end
end
