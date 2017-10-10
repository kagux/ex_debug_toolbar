defmodule ExDebugToolbar.DashboardView do
  @moduledoc false

  use ExDebugToolbar.Web, :view

  def header(_), do: "Requests"

  def description(_), do: "Overview of all recorded requests"

  def count_logs(requests) do
    requests
    |> Stream.map(&(&1.logs))
    |> Stream.map(&length/1)
    |> Enum.sum
  end

  def count_ecto_queries(requests) do
    requests
    |> Stream.map(&(&1.ecto))
    |> Stream.map(&length/1)
    |> Enum.sum
  end

  def count_breakpoints(requests) do
    requests
    |> Stream.map(&(&1.breakpoints))
    |> Stream.map(&(&1.count))
    |> Enum.sum
  end
end
