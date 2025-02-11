defmodule Noted.Repo.Migrations.CreateTeamMemberships do
  use Ecto.Migration

  def change do
    create table(:team_memberships) do
      add :team_id, references(:teams, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :role, :team_role, null: false

      timestamps()
    end

    create unique_index(:team_memberships, [:team_id, :user_id])
  end
end
