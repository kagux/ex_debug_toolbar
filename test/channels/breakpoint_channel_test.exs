defmodule ExDebugToolbar.BreakpointChannelTest do
  use ExDebugToolbar.ChannelCase, async: true

  alias ExDebugToolbar.BreakpointChannel
  alias ExDebugToolbar.ToolbarView
  require ExDebugToolbar

  setup :start_request

  test "joining and interacting with breakpoint" do
    ExDebugToolbar.pry
    {:ok, request} = get_request()
    breakpoint = request.breakpoints.entries |> Map.values |> hd
    topic = "breakpoint:#{ToolbarView.breakpoint_uuid(request, breakpoint)}"

    # initial output
    {:ok, _, socket} = socket() |> subscribe_and_join(BreakpointChannel, topic, %{})

    # echo input
    push socket, "input", %{"input" => "€"}
  end

  test "it returns error on join if breakpoint doesn't exist" do
    topic = "breakpoint:invalid_id"
    assert {:error, %{reason: _}} = socket() |> subscribe_and_join(BreakpointChannel, topic, %{})
  end
end
