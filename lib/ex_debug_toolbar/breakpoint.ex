defmodule ExDebugToolbar.Breakpoint do
  @moduledoc false

  alias ExDebugToolbar.Breakpoint.{IEx.Server, Pry}

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

  defdelegate start_iex(breakpoint_id, output_pid), to: Server, as: :start_link
  defdelegate send_input_to_iex(pid, input), to: Server, as: :send_input
  defdelegate stop_iex(pid), to: Server, as: :stop
  defdelegate code_snippet(env), to: Pry
end
