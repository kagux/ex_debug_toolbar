defmodule ExDebugToolbar.Plug.Router do
  use Plug.Router

  plug :match
  plug :dispatch

  forward "/__ex_debug_toolbar__", to: ExDebugToolbar.Endpoint
  forward "/", to: ExDebugToolbar.Plug.Pipeline
end
