defmodule ExDebugToolbar.ToolbarChannelTest do
  use ExDebugToolbar.CollectorCase, async: true
  use ExDebugToolbar.ChannelCase
  alias ExDebugToolbar.ToolbarChannel

  setup :start_request

  test "it returns request upon joining toolbar channel" do
    {:ok, payload, _} = socket() |> join(ToolbarChannel, "toolbar:request", %{"id" => @request_id})
    assert %{} = payload
    assert payload |> Map.has_key?(:html)
  end

  test "it returns an error if request could not be retrieved" do
    {:error, error} = socket() |> join(ToolbarChannel, "toolbar:request", %{"id" => "wrong_id"})
    assert %{reason: :not_found} = error
  end
end
