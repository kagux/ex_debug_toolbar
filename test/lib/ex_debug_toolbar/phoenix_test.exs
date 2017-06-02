
defmodule ExDebugToolbar.PhoenixTest do
  use ExUnit.Case, async: true
  use Plug.Test
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

  describe "requests to __ex_debug_toolbar__" do
    setup do
      conn = make_request("/__ex_debug_toolbar__/path")
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
    |> Map.put(:assigns, Map.new(assigns))
    |> Endpoint.call(%{})
  end
end
