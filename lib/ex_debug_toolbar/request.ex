defmodule ExDebugToolbar.Request do
  @moduledoc false

  alias ExDebugToolbar.Data.Timeline

  defstruct [
    pid: nil,
    uuid: nil,
    created_at: nil,
    conn: %Plug.Conn{},
    ecto: [],
    logs: [],
    timeline: %Timeline{},
    stopped?: false
  ]
end
