defmodule NotedWeb.TeamController do
  use NotedWeb, :controller
  alias Noted.Schemas.Team
  alias Noted.Contexts.Teams
  import Noted.Authorization

  def select(conn, %{"team_id" => team_id}) do
    conn
    |> put_session(:team_id, team_id)
    |> redirect(to: "/app/workspace")
  end

  def logout(conn, _params) do
    conn
    |> delete_session(:team_id)
    |> redirect(to: "/app")
  end

  def leave(conn, %{"user_id" => user_id, "team_id" => team_id}) do
    with true <- Teams.is_last_team_member?(user_id, team_id),
         {:ok, _deleted_team} <- Teams.delete_team(team_id) do
      conn
      |> put_flash(:info, "You have left the team")
      |> delete_session(:team_id)
      |> redirect(to: "/app")
    else
      false ->
        Teams.remove_team_member!(user_id, team_id)
        Phoenix.PubSub.broadcast(Noted.PubSub, "workspace:#{team_id}", :update_team_workspace)

        conn
        |> put_flash(:info, "You have left the team")
        |> delete_session(:team_id)
        |> redirect(to: "/app")

      {:error, %Ecto.Changeset{}} ->
        conn
        |> put_flash(:error, "An unexpected error occurred")
        |> redirect(to: "/app/workspace")
    end
  end

  def delete(conn, %{"team_id" => team_id}) do
    user_id = conn.assigns.current_user.id
    team_member = Teams.get_team_member(user_id, team_id)

    with true <- can(team_member.role) |> delete?(Team),
         {:ok, deleted_team} <- Teams.delete_team(team_id) do
      Phoenix.PubSub.broadcast(
        Noted.PubSub,
        "workspace:#{deleted_team.id}",
        {:force_team_logout, deleted_team.id}
      )

      conn
      |> put_flash(:info, "Team #{deleted_team.name} deleted successfully!")
      |> delete_session(:team_id)
      |> redirect(to: "/app")
    else
      false ->
        conn
        |> put_flash(:error, "You are not allowed to perform this action")
        |> redirect(to: "/app/workspace")

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "An unexpected error ocurred")
        |> redirect(to: "/app/workspace")
    end
  end
end
