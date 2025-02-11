defmodule Noted.Schemas.TeamMembership do
  use Noted.Schema
  import Ecto.Changeset
  alias Noted.Schemas.{Team, User}

  schema "team_memberships" do
    field :role, Ecto.Enum, values: [:admin, :member]

    belongs_to :team, Team
    belongs_to :user, User

    timestamps()
  end

  def changeset(team_membership, attrs \\ %{}) do
    team_membership
    |> cast(attrs, [:role, :team_id, :user_id])
    |> validate_required([:role, :team_id, :user_id])
    |> unique_constraint(:team_id, name: :team_memberships_team_id_user_id_index)
  end
end
