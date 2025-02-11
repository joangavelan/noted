defmodule Noted.Schemas.Team do
  use Noted.Schema
  import Ecto.Changeset
  alias Noted.Schemas.{TeamMembership, Invitation}

  schema "teams" do
    field :name, :string

    has_many :team_memberships, TeamMembership
    has_many :invitations, Invitation

    timestamps()
  end

  @doc false
  def changeset(team, attrs \\ %{}) do
    team
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> validate_length(:name, min: 3, max: 100, count: :bytes)
  end
end
