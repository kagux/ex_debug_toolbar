defmodule ExDebugToolbar.Breakpoint.ClientNode do
  alias ExDebugToolbar.Breakpoint.ServerNode
  alias ExDebugToolbar.Breakpoint

  def run(breakpoint_id) do
    set_cookie()
    true = ServerNode.get_name() |> Node.connect
    # :timer.sleep 1000
    %Breakpoint{binding: binding, env: env} = ServerNode.get_breakpoint(breakpoint_id)
    IEx.pry binding, env, 5000
  end

  defp set_cookie do
    Node.set_cookie node(), ServerNode.get_cookie()
  end
end
