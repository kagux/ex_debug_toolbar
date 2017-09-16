defmodule ExDebugToolbar.Request do
  @moduledoc false

  alias ExDebugToolbar.Data.{Breakpoints, Timeline}

  defstruct [
    pid: nil,
    uuid: nil,
    created_at: nil,
    conn: %Plug.Conn{},
    ecto: [],
    logs: [],
    breakpoints: %Breakpoints{},
    timeline: %Timeline{},
    stopped?: false
  ]
end
