defmodule ExDebugToolbar.DashboardView do
  @moduledoc false

  use ExDebugToolbar.Web, :view

  def header(_), do: "History"

  def description(_), do: "Overview of all recorded requests"
end
