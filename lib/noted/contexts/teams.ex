defmodule Noted.Contexts.Teams do
  @moduledoc """
  The Teams Context.
  """
  import Ecto.Query, only: [from: 2]
  alias Noted.Repo
  alias Noted.Schemas.{Team, TeamMembership, User}

  def list_user_teams(user_id) do
    query =
      from t in Team,
        join: tm in assoc(t, :team_memberships),
        where: tm.user_id == ^user_id,
        select: %Team{id: t.id, name: t.name}

    Repo.all(query)
  end

  def create_team(attrs, user_id) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(:team, Team.changeset(%Team{}, attrs))
    |> Ecto.Multi.insert(:membership, fn %{team: team} ->
      TeamMembership.changeset(%TeamMembership{}, %{
        team_id: team.id,
        user_id: user_id,
        role: "admin"
      })
    end)
    |> Repo.transaction()
  end

  def get_team_workspace!(team_id, user_id) do
    query =
      from t in Team,
        where: t.id == ^team_id,
        # Ensure the user is a member by verifying at least one membership record exists for them.
        where:
          fragment(
            "EXISTS (SELECT 1 FROM team_memberships tm WHERE tm.team_id = ? AND tm.user_id = ?)",
            t.id,
            type(^user_id, :binary_id)
          ),
        # Join memberships and preload them along with the associated user data.
        left_join: tm in assoc(t, :team_memberships),
        left_join: tm_u in assoc(tm, :user),
        left_join: inv in assoc(t, :invitations),
        left_join: inv_u in assoc(inv, :invited_user),
        preload: [team_memberships: {tm, user: tm_u}, invitations: {inv, invited_user: inv_u}]

    Repo.one!(query)
  end

  def search_users_to_invite(search_term, current_user_id, team_id) do
    pattern = "%" <> search_term <> "%"

    query =
      from u in User,
        left_join: tm in TeamMembership,
        on: tm.user_id == u.id and tm.team_id == ^team_id,
        where: ilike(u.name, ^pattern) or ilike(u.email, ^pattern),
        where: u.id != ^current_user_id,
        limit: 5,
        select: %{
          id: u.id,
          name: u.name,
          picture: u.picture,
          is_team_member: not is_nil(tm.id),
          role: tm.role
        }

    Repo.all(query)
  end

  def add_team_member(user_id, team_id, role \\ "member") do
    %TeamMembership{}
    |> TeamMembership.changeset(%{
      user_id: user_id,
      team_id: team_id,
      role: role
    })
    |> Repo.insert()
  end

  def remove_team_member(membership_id) do
    membership = get_team_membership!(membership_id)

    Repo.delete(membership)
  end

  def remove_team_member!(user_id, team_id) do
    TeamMembership
    |> Repo.get_by!(team_id: team_id, user_id: user_id)
    |> Repo.delete!()
  end

  def change_member_role(membership_id, new_role) do
    membership = get_team_membership!(membership_id)

    membership
    |> TeamMembership.changeset(%{role: new_role})
    |> Repo.update()
  end

  def get_team_membership!(id) do
    Repo.get!(TeamMembership, id)
  end

  def delete_team(id) do
    team = Repo.get!(Team, id)

    Repo.delete(team)
  end
end
