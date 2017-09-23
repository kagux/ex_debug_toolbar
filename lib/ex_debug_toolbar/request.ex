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
end
