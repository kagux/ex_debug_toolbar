defmodule ExDebugToolbar.Router do
  @moduledoc false

  use ExDebugToolbar.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end


  scope "/api", ExDebugToolbar.API do
    pipe_through :api
    get "/ping", PingController, :index
  end
end
