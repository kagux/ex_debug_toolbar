defmodule ExDebugToolbar.Request do
  alias ExDebugToolbar.Data.Timeline

  defstruct [
    id: nil,
    created_at: nil,
    conn: %Plug.Conn{},
    ecto: [],
    logs: [],
    timeline: %Timeline{}
  ]
end
