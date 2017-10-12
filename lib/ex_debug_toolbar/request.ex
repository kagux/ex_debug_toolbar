defmodule ExDebugToolbar.Request do
  @moduledoc false

  alias ExDebugToolbar.Data.{BreakpointCollection, Timeline}

  defstruct [
    pid: nil,
    uuid: nil,
    created_at: nil,
    conn: %Plug.Conn{},
    ecto: [],
    logs: [],
    breakpoints: %BreakpointCollection{},
    timeline: %Timeline{},
    stopped?: false
  ]

  def group_similar(requests) do
    {group, acc} = requests
     |> Enum.reduce({[], []}, fn
      request, {[],[]} ->
        {[request], []}
      request, {[prev_request | _] = group, acc} ->
        if similar?(request, prev_request) do
          {[request | group], acc}
        else
          {[request], [group | acc]}
        end
    end)

    [group | acc] |> Enum.reverse |> Enum.map(&Enum.reverse/1)
  end

  def sort_by_date(requests) do
    Enum.sort(requests, &(NaiveDateTime.compare(&2.created_at, &1.created_at) == :lt))
  end

  defp similar?(%{conn: conn}, %{conn: prev_conn}) do
    conn.status == prev_conn.status and
    conn.method == prev_conn.method and
    conn.request_path == prev_conn.request_path
  end
end
