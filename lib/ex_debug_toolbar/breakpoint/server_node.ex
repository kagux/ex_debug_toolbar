defmodule ExDebugToolbar.Breakpoint.ServerNode do
  @moduledoc false

  @cookie :secret
  @server :breakpoint_host

  def start_link do
    System.cmd "epmd", ["-daemon"]
    case Node.start get_name() do
      {:ok, _} = result ->
        set_cookie()
        result
      _ -> :error
    end
  end

  def get_cookie, do: @cookie

  def get_name do
    {:ok, hostname} = :inet.gethostname
    :"#{@server}@#{hostname}"
  end

  def get_breakpoint(breakpoint_id) do
    case :rpc.call(get_name(), ExDebugToolbar, :get_breakpoint, [breakpoint_id]) do
      {:ok, breakpoint} -> breakpoint
      _ -> :error
    end
  end

  defp set_cookie do
    Node.set_cookie node(), get_cookie()
  end
end
