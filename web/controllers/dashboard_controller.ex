defmodule ExDebugToolbar.DashboardController do
  @moduledoc false

  use ExDebugToolbar.Web, :controller

  plug :put_layout, {ExDebugToolbar.DashboardLayoutView, :app}

  def show(conn, _) do
    conn |> render("show.html")
  end
end
