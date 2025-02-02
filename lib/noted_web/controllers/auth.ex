defmodule NotedWeb.AuthController do
  use NotedWeb, :controller

  def login_page(conn, _params) do
    is_authenticated = get_session(conn, :user_id) != nil

    if is_authenticated do
      redirect(conn, to: "/app")
    else
      render(conn, :login_page)
    end
  end

  def logout(conn, _params) do
    conn
    |> delete_session(:user_id)
    |> put_flash(:info, "Logged out successfully!")
    |> redirect(to: "/login")
  end
end
