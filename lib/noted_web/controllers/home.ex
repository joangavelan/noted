defmodule NotedWeb.HomeController do
  use NotedWeb, :controller

  def index(conn, _params) do
    render(conn, :index)
  end
end
