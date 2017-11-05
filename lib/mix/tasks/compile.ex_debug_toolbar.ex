Code.compiler_options(ignore_module_conflict: true)

defmodule Mix.Tasks.Compile.ExDebugToolbar do
  @moduledoc false

  use Mix.Task

   def run(_) do
     Code.require_file "lib/ex_debug_toolbar/application.ex"
     ExDebugToolbar.Application.update_config()
   end
end

Code.compiler_options(ignore_module_conflict: false)
