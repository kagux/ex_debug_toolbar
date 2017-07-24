defmodule ExDebugToolbar.Breakpoint.IEx.Shell do

  @default_cmd """
    stty echo
    clear
    iex --sname %{node_name} -S mix breakpoint.client %{breakpoint_id}
  """

  def start(breakpoint_id) do
    with {:ok, pid, _os_pid} <- start_shell_process(),
         :ok <- start_iex_process(pid, breakpoint_id),
      do: {:ok, pid}
    else error -> error
  end

  def stop(pid), do: :exec.stop(pid)

  def send_input(pid, input), do: :exec.send(pid, input)

  defp start_shell_process do
    :exec.run('$SHELL', [:stdin, :stdout, :stderr, :pty])
  end

  defp start_iex_process(pid, breakpoint_id) do
    :ex_debug_toolbar
    |> Application.get_env(:iex_shell_cmd, @default_cmd)
    |> String.replace("%{node_name}", node_name())
    |> String.replace("%{breakpoint_id}", breakpoint_id)
    |> (&:exec.send(pid, &1)).()
  end

  defp node_name() do
    self()
    |> inspect
    |> String.trim("#PID<")
    |> String.trim(">")
    |> String.replace(".", "-")
  end
end
