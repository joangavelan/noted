defmodule Noted.Schemas.Invitation do
  use Noted.Schema
  import Ecto.Changeset
  alias Noted.Schemas.{Team, User}

  schema "invitations" do
    belongs_to :team, Team
    belongs_to :invited_user, User
    belongs_to :invited_by_user, User

    timestamps(updated_at: false)
  end

  def changeset(invitation, attrs \\ %{}) do
    invitation
    |> cast(attrs, [:team_id, :invited_user_id, :invited_by_user_id])
    |> validate_required([:team_id, :invited_user_id, :invited_by_user_id])
    |> unique_constraint(:invited_user_id,
      name: :invitations_team_id_invited_user_id_index,
      message: "user already invited"
    )
  end
end
