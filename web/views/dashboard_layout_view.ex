defmodule ExDebugToolbar.DashboardLayoutView do
  @moduledoc false

  use ExDebugToolbar.Web, :view

  def version do
    {:ok, version} = :application.get_key(:ex_debug_toolbar, :vsn)
    "v#{version}"
  end

  def requests_count do
    ExDebugToolbar.get_all_requests() |> Enum.count
  end
end
