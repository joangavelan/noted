defmodule NotedWeb.Plugs.RequireAuth do
  import Phoenix.Controller
  import Plug.Conn

  def init(default), do: default

  def call(conn, _opts) do
    if get_session(conn, :user_id) do
      conn
    else
      conn
      |> redirect(to: "/login")
      |> halt()
    end
  end
end
