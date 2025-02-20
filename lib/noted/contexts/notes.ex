defmodule Noted.Contexts.Notes do
  @moduledoc """
  The Notes Context.
  """
  alias Noted.Repo
  alias Noted.Schemas.Note

  def create_note(team_membership_id, team_id, attrs) do
    attrs
    |> Map.put("team_membership_id", team_membership_id)
    |> Map.put("team_id", team_id)
    |> then(&Note.changeset(%Note{}, &1))
    |> Repo.insert()
  end

  def update_note(%Note{} = note, attrs) do
    note
    |> Note.changeset(attrs)
    |> Repo.update()
  end

  def delete_note(note) do
    Repo.delete(note)
  end

  def get_note!(id) do
    Repo.get!(Note, id)
  end
end
