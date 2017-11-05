defmodule ExDebugToolbar.ToolbarChannelTest do
  use ExDebugToolbar.ChannelCase, async: true
  alias ExDebugToolbar.ToolbarChannel

  setup :start_request

  describe "join" do
    test "it returns stopped request upon joining toolbar channel" do
      stop_request(@request_id)
      {:ok, payload, _} = socket() |> join(ToolbarChannel, "toolbar:request:#{@request_id}", %{})
      assert %{} = payload
      assert payload |> Map.has_key?(:html)
    end

    test "it returns pending message if request is still running" do
      {:ok, payload, _} = socket() |> join(ToolbarChannel, "toolbar:request:#{@request_id}", %{})
      assert :pending == payload
    end

    test "it returns an error if request could not be retrieved" do
      {:error, error} = socket() |> join(ToolbarChannel, "toolbar:request:wrong_id", %{})
      assert %{reason: :not_found} = error
    end
  end
end
