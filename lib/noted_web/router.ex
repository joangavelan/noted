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

  scope "/team", NotedWeb do
    pipe_through [:browser, :is_authenticated]

    post "/select", TeamController, :select
    delete "/leave", TeamController, :leave
    get "/logout", TeamController, :logout
    delete "/delete", TeamController, :delete
  end

  live_session :protected_liveviews, on_mount: NotedWeb.LiveHooks.RequireAuth do
    scope "/app", NotedWeb do
      pipe_through :browser

      live "/", Live.Notes.Teams
      live "/new-team", Live.Notes.NewTeam
      live "/workspace", Live.Notes.Workspace
    end
  end

  scope "/oauth", NotedWeb do
    pipe_through :browser

    get "/:provider", OAuth2Controller, :request
    get "/:provider/callback", OAuth2Controller, :callback
  end
end
