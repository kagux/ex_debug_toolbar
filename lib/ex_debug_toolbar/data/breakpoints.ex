alias ExDebugToolbar.Data.Collection
alias ExDebugToolbar.Breakpoint

defmodule ExDebugToolbar.Data.Breakpoints do
  @moduledoc false

  defstruct [count: 0, entries: []]

  def find(breakpoints, id) do
    case Enum.find(breakpoints.entries, &(&1.id == id)) do
      nil -> {:error, :not_found}
      breakpoint -> {:ok, breakpoint}
    end
  end
end

alias ExDebugToolbar.Data.Breakpoints

defimpl Collection, for: Breakpoints do
  @breakpoints_limit Application.get_env(:ex_debug_toolbar, :breakpoints_limit, 10)

  def add(%{count: @breakpoints_limit} = breakpoints, %Breakpoint{}), do: breakpoints
  def add(breakpoints, %Breakpoint{} = breakpoint) do
    %{
      breakpoints |
      entries: [breakpoint | breakpoints.entries],
      count: breakpoints.count + 1
    }
  end
end
