defmodule ExDebugToolbar.DashboardLayoutView do
  @moduledoc false

  use ExDebugToolbar.Web, :view

  def version do
    {:ok, version} = :application.get_key(:ex_debug_toolbar, :vsn)
    "v#{version}"
  end
end
