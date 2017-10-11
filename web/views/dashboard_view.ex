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

  def requests_chart_data(requests) do
    requests
    |> requests_durations
    |> inspect(limit: :infinity)
  end

  def requests_chart_max_y([]), do: 1
  def requests_chart_max_y(requests) do
    drop_count = case length(requests) do
      l when l < 3 -> 0
      l when l < 10 -> 1
      _ -> requests |> length |> Kernel.*(0.05) |> round
    end

    requests
    |> requests_durations
    |> Enum.sort
    |> Enum.drop(-drop_count)
    |> Enum.max
  end

  defp requests_durations(requests) do
    requests
    |> Enum.map(&(&1.timeline.duration))
    |> Enum.map(&System.convert_time_unit(&1, :native, :micro_seconds))
    |> Enum.filter(&(&1 > 0))
  end
end
