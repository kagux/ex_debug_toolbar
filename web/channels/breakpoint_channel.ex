defmodule ExDebugToolbar.BreakpointChannel do
  @moduledoc false

  use ExDebugToolbar.Web, :channel
  alias ExDebugToolbar.Breakpoint

  def join("breakpoint:" <> raw_breakpoint_id, _payload, socket) do
    with {:ok, breakpoint_id} <- Breakpoint.UUID.from_string(raw_breakpoint_id),
         {:ok, _} <- ExDebugToolbar.get_breakpoint(breakpoint_id),
         {:ok, iex} <- Breakpoint.start_iex(breakpoint_id, self())
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
