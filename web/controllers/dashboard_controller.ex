defmodule ExDebugToolbar.DashboardController do
  @moduledoc false

  use ExDebugToolbar.Web, :controller

  plug :put_layout, {ExDebugToolbar.DashboardLayoutView, :app}

  def show(conn, _) do
    conn
    |> assign(:requests, ExDebugToolbar.get_all_requests())
    |> render("show.html")
  end
end
