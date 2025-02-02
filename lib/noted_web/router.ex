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

  pipeline :is_authenticated do
    plug NotedWeb.Plugs.RequireAuth
    plug NotedWeb.Plugs.FetchUser
  end

  scope "/", NotedWeb do
    pipe_through :browser

    get "/", HomeController, :index
    get "/login", AuthController, :login_page
    post "/logout", AuthController, :logout
  end

  live_session :protected_liveviews, on_mount: NotedWeb.LiveHooks.RequireAuth do
    scope "/app", NotedWeb do
      pipe_through :browser

      live "/", Live.Notes.Index
    end
  end

  scope "/oauth", NotedWeb do
    pipe_through :browser

    get "/:provider", OAuth2Controller, :request
    get "/:provider/callback", OAuth2Controller, :callback
  end
end
