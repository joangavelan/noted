defmodule Noted.Schemas.Note do
  use Noted.Schema
  import Ecto.Changeset
  alias Noted.Schemas.{Team, TeamMembership}

  schema "notes" do
    field :description, :string

    belongs_to :team, Team
    belongs_to :team_membership, TeamMembership

    timestamps()
  end

  @doc false
  def changeset(note, attrs \\ %{}) do
    note
    |> cast(attrs, [:description, :team_id, :team_membership_id])
    |> validate_required([:description, :team_id, :team_membership_id])
    |> validate_length(:description, min: 3, max: 255, count: :bytes)
  end
end
