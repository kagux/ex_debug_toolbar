defmodule ExDebugToolbar.Breakpoint do
  @moduledoc false

  alias ExDebugToolbar.Breakpoint.{IEx.Server, Pry}

  defstruct [
    :id,
    :request_id,
    :file,
    :line,
    :env,
    :binding,
    :code_snippet,
    :inserted_at
  ]

  defmodule UUID do
    defstruct [:request_id, :breakpoint_id]

    def from_string(uuid) do
      case String.split(uuid, "_-_") do
        [request_id, breakpoint_id] ->
          {:ok, %__MODULE__{request_id: request_id, breakpoint_id: String.to_integer(breakpoint_id)}}
        _ -> {:error, "cannot parse uuid #{uuid}"}
      end
    end
  end

  defdelegate start_iex(breakpoint_id, output_pid), to: Server, as: :start_link
  defdelegate send_input_to_iex(pid, input), to: Server, as: :send_input
  defdelegate stop_iex(pid), to: Server, as: :stop
  defdelegate code_snippet(env), to: Pry
end

defimpl String.Chars, for: ExDebugToolbar.Breakpoint.UUID do
  def to_string(%{request_id: request_id, breakpoint_id: breakpoint_id}) do
    "#{request_id}_-_#{breakpoint_id}"
  end
end
