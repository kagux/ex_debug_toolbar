defmodule ExDebugToolbar.BreakpointChannel do
  @moduledoc false

  use ExDebugToolbar.Web, :channel
  alias ExDebugToolbar.Breakpoint
  alias ExDebugToolbar.Data.Breakpoints

  def join("breakpoint:" <> _id, payload, socket) do
    with request_id <- payload["request_id"],
         breakpoint_id <- payload["breakpoint_id"],
         {:ok, _} <- ExDebugToolbar.get_breakpoint(request_id, breakpoint_id),
         {:ok, iex} <- Breakpoint.start_iex(request_id, breakpoint_id, self())
    do
      {:ok, assign(socket, :iex, iex)}
    else
      {:error, reason} -> {:error, %{reason: reason}}
    end
  end

  def handle_in("input", %{"input" => input}, socket) do
    Breakpoint.send_input_to_iex(socket.assigns[:iex], input)
    {:noreply, socket}
  end

  def handle_info({:output, output}, socket) do
    push(socket, "output", %{output: output})
    {:noreply, socket}
  end

  def terminate(msg, socket) do
    Breakpoint.stop_iex(socket.assigns[:iex])
    msg
  end
end
