defmodule Mix.Tasks.Breakpoint.Client do
  @moduledoc false

  use Mix.Task

   def run(args) do
     args |> hd |> ExDebugToolbar.Breakpoint.ClientNode.run
   end
end
