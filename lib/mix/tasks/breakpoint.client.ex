defmodule Mix.Tasks.Breakpoint.Client do
  @moduledoc false

  use Mix.Task
  alias ExDebugToolbar.Breakpoint.UUID

   def run(args) do
     {options, _, _} = OptionParser.parse(args, switches: [breakpoint_id: :string])
     {:ok, breakpoint_id} = options |> Keyword.fetch!(:breakpoint_id) |> UUID.from_string
     ExDebugToolbar.Breakpoint.ClientNode.run(breakpoint_id)
   end
end
