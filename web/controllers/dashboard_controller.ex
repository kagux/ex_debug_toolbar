defmodule ExDebugToolbar.DashboardController do
  @moduledoc false

  use ExDebugToolbar.Web, :controller

  def show(conn, _) do
    conn |> put_layout(false) |> render("show.html")
  end
end
