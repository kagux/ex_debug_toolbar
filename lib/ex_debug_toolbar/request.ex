defmodule ExDebugToolbar.Request do
  alias ExDebugToolbar.Data.{Conn, EctoQueries, Logs, Timeline}

  defstruct [
    id: nil,
    created_at: nil,
    conn: %Conn{},
    ecto: %EctoQueries{},
    logs: %Logs{},
    timeline: %Timeline{}
  ]
end
