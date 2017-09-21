alias ExDebugToolbar.Data.Collection
alias ExDebugToolbar.Breakpoint

defmodule ExDebugToolbar.Data.BreakpointCollection do
  @moduledoc false

  defstruct [count: 0, entries: %{}]

  def find(breakpoints, id) do
    case Map.fetch(breakpoints.entries, id) do
      :error -> {:error, :not_found}
      {:ok, breakpoint} -> {:ok, breakpoint}
    end
  end
end

alias ExDebugToolbar.Data.BreakpointCollection

defimpl Collection, for: BreakpointCollection do
  @breakpoints_limit Application.get_env(:ex_debug_toolbar, :breakpoints_limit, 10)

  def add(%{count: @breakpoints_limit} = breakpoints, %Breakpoint{}), do: breakpoints
  def add(breakpoints, %Breakpoint{} = breakpoint) do
    %{
      breakpoints |
      entries: Map.put(breakpoints.entries, breakpoint.id, breakpoint),
      count: breakpoints.count + 1
    }
  end
end
