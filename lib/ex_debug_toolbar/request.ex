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

  def sort_by_date(requests) do
    Enum.sort(requests, &(NaiveDateTime.compare(&2.created_at, &1.created_at) == :lt))
  end

  def filter_stopped(requests) do
    Enum.filter(requests, &(&1.stopped?))
  end
end
