defmodule ExDebugToolbar.Breakpoint do
  @moduledoc false

  alias ExDebugToolbar.Breakpoint.{IEx.Server, Pry}
  alias ExDebugToolbar.{Breakpoint, Request}

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

  def serialize!(%__MODULE__{} = breakpoint) do
    breakpoint
    |> :erlang.term_to_binary
    |> Base.encode64
  end

  def unserialize!(string) do
    breakpoint = string
    |> Base.decode64!
    |> :erlang.binary_to_term

    case breakpoint do
      %__MODULE__{} -> breakpoint
      term -> raise ArgumentError, "Expected string to be base64 encoded %Breakpoint{}, but got #{inspect(term)}"
    end
  end

  def get_code_snippet_start_line(%Breakpoint{code_snippet: code_snippet}) do
    code_snippet |> hd |> Tuple.to_list |> List.last
  end

  def get_sorted_binding(%Breakpoint{binding: binding}) do
    binding |> Keyword.keys |> Enum.sort
  end

  def get_relative_line(%Breakpoint{code_snippet: code_snippet, line: line}) do
    code_snippet
    |> Enum.find_index(fn {_, n} -> n == line end)
    |> Kernel.+(1)
  end

  def get_uuid(%Request{uuid: request_id}, %Breakpoint{id: id}) do
    %Breakpoint.UUID{request_id: request_id, breakpoint_id: id}
  end
end
