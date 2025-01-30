defmodule NotedWeb.Router do
  use NotedWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {NotedWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", NotedWeb do
    pipe_through :browser

    get "/", HomeController, :index
  end
end
