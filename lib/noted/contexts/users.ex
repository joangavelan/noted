defmodule Noted.Contexts.Users do
  @moduledoc """
  The Users Context.
  """
  alias Noted.Repo
  alias Noted.Schemas.User

  def upsert_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert(
      on_conflict: {:replace_all_except, [:id, :email, :created_at]},
      conflict_target: :email,
      returning: [:id]
    )
  end

  def get_user!(id) do
    Repo.get!(User, id)
  end
end
