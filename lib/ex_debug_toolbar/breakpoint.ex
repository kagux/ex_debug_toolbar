defmodule ExDebugToolbar.Breakpoint do
  @moduledoc false

  alias ExDebugToolbar.Breakpoint.{IEx.Server, Pry}

  defstruct [
    :id,
    :file,
    :line,
    :env,
    :binding,
    :code_snippet,
    :inserted_at
  ]

  defdelegate start_iex(breakpoint, output_pid), to: Server, as: :start_link
  defdelegate send_input_to_iex(pid, input), to: Server, as: :send_input
  defdelegate stop_iex(pid), to: Server, as: :stop
  defdelegate code_snippet(env), to: Pry

  def serialize(%__MODULE__{} = breakpoint) do
    breakpoint
    |> :erlang.term_to_binary
    |> Base.encode64
  end

  def unserialize(string) do
    string
    |> Base.decode64!
    |> :erlang.binary_to_term
  end
end
