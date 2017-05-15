defmodule ExDebugToolbar.Data.Timeline.Action do
  defstruct [:action, :event_name]
end
alias ExDebugToolbar.Data.{Collectable, Timeline.Action, Timeline}

defimpl Collectable, for: Action do
  def init_collection(_), do: %Timeline{}
end
