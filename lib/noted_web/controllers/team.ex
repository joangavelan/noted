defmodule NotedWeb.TeamController do
  use NotedWeb, :controller
  alias Noted.Contexts.Teams

  def select(conn, %{"team_id" => team_id}) do
    conn
    |> put_session(:team_id, team_id)
    |> redirect(to: "/app/workspace")
  end

  def logout_team(conn, _params) do
    conn
    |> delete_session(:team_id)
    |> redirect(to: "/app")
  end

  def leave_team(conn, %{"user_id" => user_id, "team_id" => team_id}) do
    Teams.remove_team_member!(user_id, team_id)

    Phoenix.PubSub.broadcast(Noted.PubSub, "workspace:#{team_id}", :update_team_workspace)

    conn
    |> delete_session(:team_id)
    |> redirect(to: "/app")
  end
end
