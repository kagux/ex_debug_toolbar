defmodule ExDebugToolbar.BreakpointChannel do
  @moduledoc false

  use ExDebugToolbar.Web, :channel
  alias ExDebugToolbar.Breakpoint

  def join("breakpoint:" <> id, _payload, socket) do
    case ExDebugToolbar.get_breakpoint(id) do
      {:ok, _} ->
        {:ok, iex} = Breakpoint.start_iex(id, self())
        {:ok, assign(socket, :iex, iex)}
      {:error, reason} ->
        {:error, %{reason: reason}}
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
