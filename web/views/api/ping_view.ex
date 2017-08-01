defmodule ExDebugToolbar.API.PingView do
  use ExDebugToolbar.Web, :view

  def render("index.json", _params) do
    :pong
  end
end
