defmodule ExDebugToolbar.Breakpoint.UUID do
  defstruct [:request_id, :breakpoint_id]

  def from_string(uuid) do
    case String.split(uuid, "-") do
      [request_id, breakpoint_id] ->
        {:ok, %__MODULE__{request_id: request_id, breakpoint_id: breakpoint_id}}
      _ -> {:error, "cannot parse uuid #{uuid}"}
    end
  end
end

defimpl String.Chars, for: ExDebugToolbar.Breakpoint.UUID do
  def to_string(%{request_id: request_id, breakpoint_id: breakpoint_id}) do
    "#{request_id}-#{breakpoint_id}"
  end
end
