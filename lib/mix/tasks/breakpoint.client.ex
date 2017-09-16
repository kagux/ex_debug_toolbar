defmodule Mix.Tasks.Breakpoint.Client do
  @moduledoc false

  use Mix.Task

   def run(args) do
     {options, _, _} = OptionParser.parse(args, switches: [request_id: :string, breakpoint_id: :string])
     request_id = Keyword.fetch!(options, :request_id)
     breakpoint_id = Keyword.fetch!(options, :breakpoint_id)
     ExDebugToolbar.Breakpoint.ClientNode.run(request_id, breakpoint_id)
   end
end
