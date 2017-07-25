defmodule Mix.Tasks.Compile.ExDebugToolbar do
  use Mix.Task

   def run(_) do
     Code.require_file "lib/ex_debug_toolbar/application.ex"
     ExDebugToolbar.Application.update_config()
   end
end
