defmodule Mix.Tasks.Breakpoint.Client do
  @moduledoc false

  use Mix.Task
  alias ExDebugToolbar.Breakpoint

   def run(args) do
     {options, _, _} = OptionParser.parse(args, switches: [breakpoint: :string])
     breakpoint = options |> Keyword.fetch!(:breakpoint) |> Breakpoint.unserialize
     ExDebugToolbar.Breakpoint.ClientNode.run(breakpoint)
   end
end
