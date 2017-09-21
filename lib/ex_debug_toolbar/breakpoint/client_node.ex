defmodule ExDebugToolbar.Breakpoint.ClientNode do
  @moduledoc false

  alias ExDebugToolbar.Breakpoint.ServerNode
  alias ExDebugToolbar.Breakpoint

  def run(request_id, breakpoint_id) do
    set_cookie()
    true = ServerNode.get_name() |> Node.connect
    %Breakpoint{binding: binding, env: env} = ServerNode.get_breakpoint(request_id, breakpoint_id)
    if old_iex_version?() do
      apply(IEx, :pry, [binding, env, 5000])
    else
      apply(IEx.Pry, :pry, [binding, env])
    end
  end

  defp set_cookie do
    Node.set_cookie node(), ServerNode.get_cookie()
  end

  defp old_iex_version? do
    :functions
    |> IEx.__info__
    |> Keyword.has_key?(:pry)
  end
end
