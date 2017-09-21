alias ExDebugToolbar.Data.Collection

defmodule ExDebugToolbar.Data.BreakpointCollection do
  @moduledoc false
  defstruct [count: 0, entries: %{}]

  defmodule Breakpoint do
    defstruct [
      :id,
      :pid,
      :file,
      :line,
      :env,
      :binding,
      :code_snippet,
      :inserted_at
    ]
  end

  def find(breakpoints, id) do
    case Map.get(breakpoints.entries, id) do
      nil -> {:error, :not_found}
      breakpoint -> {:ok, breakpoint}
    end
  end
end

alias ExDebugToolbar.Data.BreakpointCollection
alias ExDebugToolbar.Data.BreakpointCollection.Breakpoint

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
