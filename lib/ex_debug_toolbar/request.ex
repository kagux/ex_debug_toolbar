defmodule ExDebugToolbar.Request do
  alias ExDebugToolbar.Data.{EctoQueries, Logs, Timeline}

  defstruct [
    id: nil,
    created_at: nil,
    conn: %Plug.Conn{},
    ecto: %EctoQueries{},
    logs: %Logs{},
    timeline: %Timeline{}
  ]
end
