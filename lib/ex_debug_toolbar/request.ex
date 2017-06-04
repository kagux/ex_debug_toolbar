defmodule ExDebugToolbar.Request do
  alias ExDebugToolbar.Data.Timeline

  defstruct [
    pid: nil,
    uuid: nil,
    created_at: nil,
    conn: %Plug.Conn{},
    ecto: [],
    logs: [],
    timeline: %Timeline{}
  ]
end
