defmodule ExDebugToolbar.Breakpoint.IEx.Shell do
  @moduledoc false

  @default_cmd """
    stty echo
    clear
    iex -S mix breakpoint.client --breakpoint $BREAKPOINT
  """

  alias ExDebugToolbar.Breakpoint

  def start(breakpoint) do
    with breakpoint_env <- breakpoint_env(breakpoint),
         {:ok, pid, _os_pid} <- start_shell_process(breakpoint_env),
         :ok <- start_iex_process(pid),
      do: {:ok, pid}
    else error -> error
  end

  def stop(pid), do: :exec.stop(pid)

  def send_input(pid, input), do: :exec.send(pid, input)

  defp breakpoint_env(breakpoint) do
    breakpoint |> Breakpoint.serialize! |> to_charlist
  end
  
  defp start_shell_process(breakpoint_env) do
    :exec.run('$SHELL', [
      :stdin,
      :stdout,
      :stderr,
      :pty,
      {:env, [{'BREAKPOINT', breakpoint_env}]}
    ])
  end

  defp start_iex_process(pid) do
    :ex_debug_toolbar
    |> Application.get_env(:iex_shell_cmd, @default_cmd)
    |> (&:exec.send(pid, &1)).()
  end
end
