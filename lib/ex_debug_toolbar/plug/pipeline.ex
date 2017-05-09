defmodule ExDebugToolbar.Plug.Pipeline do
  use Plug.Builder

  plug ExDebugToolbar.Plug.CodeInjector
end
