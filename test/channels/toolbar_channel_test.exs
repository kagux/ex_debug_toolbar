defmodule ExDebugToolbar.ToolbarChannelTest do
  use ExDebugToolbar.CollectorCase, async: false
  use ExDebugToolbar.ChannelCase
  alias ExDebugToolbar.ToolbarChannel

  setup :start_request

  test "it returns request upon joining toolbar channel" do
    {:ok, payload, _} = socket() |> join(ToolbarChannel, "toolbar:request", %{"id" => @request_id})
    assert %{} = payload
    assert payload |> Map.has_key?(:html)
  end
end
