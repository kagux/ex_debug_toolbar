defmodule ExDebugToolbar.Plug do
  use Plug.Builder

  plug ExDebugToolbar.Plug.CodeInjector
end
