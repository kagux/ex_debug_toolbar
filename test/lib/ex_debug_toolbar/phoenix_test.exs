
defmodule ExDebugToolbar.PhoenixTest do
  use ExUnit.Case, async: true
  use Plug.Test
  import Supervisor.Spec
  import ExDebugToolbar.Test.Support.RequestHelpers
  alias ExDebugToolbar.Data.Timeline
  alias ExDebugToolbar.Fixtures.Endpoint

  setup_all do
    children = [supervisor(Endpoint, [])]
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
    assert Timeline.duration(request.data.timeline) > 70 * 1000 # not sure why
  end

  defp make_request(assigns \\ %{}) do
    conn(:get, "/")
    |> Map.put(:assigns, Map.new(assigns))
    |> Endpoint.call(%{})
  end
end
