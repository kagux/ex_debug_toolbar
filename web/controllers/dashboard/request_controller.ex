defmodule ExDebugToolbar.Dashboard.RequestController do
  @moduledoc false

  use ExDebugToolbar.Web, :controller
  alias ExDebugToolbar.Request

  plug :put_layout, {ExDebugToolbar.DashboardLayoutView, :app}

  def index(conn, _) do
    requests =
      ExDebugToolbar.get_all_requests()
      |> Request.filter_stopped
      |> Request.sort_by_date
    conn
    |> assign(:requests, requests)
    |> render("index.html")
  end

  def show(conn, %{"id" => request_id}) do
    request =
      case ExDebugToolbar.get_request(request_id) do
        {:ok, request} -> request
        _ -> nil
      end
    conn
    |> assign(:request, request)
    |> render("show.html")
  end
end
