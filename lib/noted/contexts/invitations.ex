defmodule Noted.Contexts.Invitations do
  @moduledoc """
  The Invitations Context.
  """
  alias Noted.Schemas.{Invitation, TeamMembership}
  alias Noted.Repo
  import Ecto.Query, only: [from: 2]

  def invite_user(invited_user_id, invited_by_user_id, team_id) do
    %Invitation{}
    |> Invitation.changeset(%{
      team_id: team_id,
      invited_user_id: invited_user_id,
      invited_by_user_id: invited_by_user_id
    })
    |> Repo.insert()
  end

  def list_user_invitations(user_id) do
    query =
      from i in Invitation,
        where: i.invited_user_id == ^user_id,
        join: t in assoc(i, :team),
        preload: [:team]

    Repo.all(query)
  end

  def accept_invitation(invitation_id) do
    invitation = get_invitation!(invitation_id)

    Ecto.Multi.new()
    |> Ecto.Multi.delete(:delete_invitation, invitation)
    |> Ecto.Multi.insert(
      :add_team_membership,
      TeamMembership.changeset(%TeamMembership{}, %{
        user_id: invitation.invited_user_id,
        team_id: invitation.team_id,
        role: "member"
      })
    )
    |> Repo.transaction()
  end

  def decline_or_cancel_invitation(invitation_id) do
    invitation = get_invitation!(invitation_id)

    Repo.delete(invitation)
  end

  def get_invitation!(invitation_id) do
    Repo.get!(Invitation, invitation_id)
  end
end
