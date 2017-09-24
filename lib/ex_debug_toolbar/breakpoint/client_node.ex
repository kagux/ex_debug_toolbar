defmodule ExDebugToolbar.Breakpoint.ClientNode do
  @moduledoc false

  alias ExDebugToolbar.Breakpoint

  def run(%Breakpoint{binding: binding, env: env}) do
    if old_iex_version?() do
      apply(IEx, :pry, [binding, env, 5000])
    else
      apply(IEx.Pry, :pry, [binding, env])
    end
  end

  defp old_iex_version? do
    :functions
    |> IEx.__info__
    |> Keyword.has_key?(:pry)
  end
end
