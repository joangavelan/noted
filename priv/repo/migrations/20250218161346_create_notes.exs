defmodule Noted.Repo.Migrations.CreateNotes do
  use Ecto.Migration

  def change do
    create table(:notes) do
      add :description, :string, null: false
      add :team_id, references(:teams, on_delete: :delete_all), null: false
      add :team_membership_id, references(:team_memberships, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:notes, [:team_id])
    create index(:notes, [:team_membership_id])
  end
end
