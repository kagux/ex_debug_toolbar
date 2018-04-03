defmodule ExDebugToolbar.Router do
  @moduledoc false

  use ExDebugToolbar.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", ExDebugToolbar.Dashboard do
    pipe_through :browser
    get "/", RequestController, :index
    resources "/requests", RequestController, only: [:show]
  end
end
