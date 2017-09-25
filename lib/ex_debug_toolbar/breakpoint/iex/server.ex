defmodule ExDebugToolbar.Breakpoint.IEx.Server do
  @moduledoc false

  alias ExDebugToolbar.Breakpoint.IEx.Shell
  use GenServer

  def start_link(breakpoint_id, output_pid) do
    GenServer.start_link(__MODULE__, {breakpoint_id, output_pid})
  end

  def stop(iex) do
    GenServer.stop(iex)
  end

  def send_input(iex, input) do
    GenServer.cast(iex, {:input, input})
  end

  def init({breakpoint, output_pid}) do
    {:ok, iex} = Shell.start(breakpoint)
    {:ok, %{output_pid: output_pid, iex: iex}}
  end

  def handle_cast({:input, input}, %{iex: iex} = state) do
    Shell.send_input(iex, input)
    {:noreply, state}
  end

  def handle_info({:stdout, _os_pid, output}, %{output_pid: output_pid} = state) do
    send(output_pid, {:output, output})
    {:noreply, state}
  end

  def handle_info({:stderr, _os_pir, output}, %{output_pid: output_pid} = state) do
    send(output_pid, {:output, output})
    {:noreply, state}
  end

  def terminate(reason, %{iex: iex}) do
    Shell.stop(iex)
    reason
  end
end
