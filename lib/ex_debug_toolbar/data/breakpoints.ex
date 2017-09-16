alias ExDebugToolbar.Data.Collection
alias ExDebugToolbar.Breakpoint

defmodule ExDebugToolbar.Data.Breakpoints do
  @moduledoc false

  defstruct [collection: []]

  def find(breakpoints, id) do
    case Enum.find(breakpoints.collection, &(&1.id == id)) do
      nil -> {:error, :not_found}
      breakpoint -> {:ok, breakpoint}
    end
  end
end

alias ExDebugToolbar.Data.Breakpoints

defimpl Collection, for: Breakpoints do
  def add(breakpoints, breakpoint) do
    %{breakpoints | collection: [breakpoint | breakpoints.collection]}
  end
end
