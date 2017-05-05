defmodule ExDebugToolbar.PageController do
  use ExDebugToolbar.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
