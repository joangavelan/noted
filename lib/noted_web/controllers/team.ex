defmodule NotedWeb.TeamController do
  use NotedWeb, :controller

  def select(conn, %{"team_id" => team_id}) do
    conn
    |> put_session(:team_id, team_id)
    |> redirect(to: "/app/workspace")
  end
end
