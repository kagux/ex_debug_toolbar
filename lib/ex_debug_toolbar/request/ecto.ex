defmodule ExDebugToolbar.Request.Ecto do
  def split_inline_and_parallel_queries(queries) do
    {inline, parallel} = queries |> Enum.split_with(fn {_, _, type} -> type == :inline end)
    %{inline: inline, parallel: parallel}
  end
end
