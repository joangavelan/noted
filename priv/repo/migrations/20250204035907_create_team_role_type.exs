defmodule Noted.Repo.Migrations.CreateTeamRoleType do
  use Ecto.Migration

  def change do
    execute(
      """
      CREATE TYPE team_role AS ENUM ('admin', 'member')
      """,
      """
      DROP TYPE team_role
      """
    )
  end
end
