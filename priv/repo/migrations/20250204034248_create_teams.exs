defmodule Noted.Repo.Migrations.CreateTeams do
  use Ecto.Migration

  def change do
    create table(:teams) do
      add :name, :varchar, size: 100, null: false

      timestamps()
    end
  end
end
