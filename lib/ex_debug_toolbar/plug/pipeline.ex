defmodule ExDebugToolbar.Plug.Pipeline do
  @moduledoc false

  use Plug.Builder

  plug ExDebugToolbar.Plug.RequestId
  plug ExDebugToolbar.Plug.CodeInjector
  plug ExDebugToolbar.Collector.ConnCollector
  plug ExDebugToolbar.Plug.CloseConn
  plug ExDebugToolbar.Plug.RemoveGlobParams
  plug ExDebugToolbar.Plug.IgnorePathMatch, ignore_paths: [
    ".*\.js",
    ".*\.css",
    ".*\.png",
    ".*\.jpg",
    ".*\.jpeg",
    ".*\.ico",
    ".*\.gif",
    ".*\.svg",
    ".*\.woff2",
  ]
end
