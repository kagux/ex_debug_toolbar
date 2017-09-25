defmodule ExDebugToolbar.Breakpoint.IEx.Shell do
  @moduledoc false

  @default_cmd """
    stty echo
    clear
    iex -S mix breakpoint.client --breakpoint-file %{breakpoint_file}
  """

  alias ExDebugToolbar.Breakpoint

  def start(breakpoint) do
    with {:ok, _} <- Temp.track,
         breakpoint_file <- breakpoint_file(breakpoint),
         {:ok, pid, _os_pid} <- start_shell_process(),
         :ok <- start_iex_process(pid, breakpoint_file),
      do: {:ok, pid}
    else error -> error
  end

  def stop(pid), do: :exec.stop(pid)

  def send_input(pid, input), do: :exec.send(pid, input)

  defp breakpoint_file(breakpoint) do
    serialized_breakpoint = breakpoint |> Breakpoint.serialize!
    Temp.open! "breakpoint", &IO.write(&1, serialized_breakpoint)
  end
  
  defp start_shell_process do
    :exec.run('$SHELL', [:stdin, :stdout, :stderr, :pty])
  end

  defp start_iex_process(pid, breakpoint_file) do
    :ex_debug_toolbar
    |> Application.get_env(:iex_shell_cmd, @default_cmd)
    |> String.replace("%{breakpoint_file}", breakpoint_file)
    |> (&:exec.send(pid, &1)).()
  end
end
