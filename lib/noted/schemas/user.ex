defmodule Noted.Schemas.User do
  use Noted.Schema
  import Ecto.Changeset

  schema "users" do
    field :name, :string
    field :email, :string
    field :picture, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs \\ %{}) do
    user
    |> cast(attrs, [:name, :email, :picture])
    |> validate_required([:name, :email, :picture])
    |> unique_constraint(:email)
  end
end
