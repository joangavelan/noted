defmodule Noted.Repo.Migrations.CreateInvitations do
  use Ecto.Migration

  def change do
    create table(:invitations) do
      add :team_id, references(:teams, on_delete: :delete_all), null: false
      add :invited_user_id, references(:users, on_delete: :delete_all), null: false
      add :invited_by_user_id, references(:users, on_delete: :delete_all), null: false

      timestamps(updated_at: false)
    end

    create unique_index(:invitations, [:team_id, :invited_user_id])
  end
end
