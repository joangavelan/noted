defmodule Noted.Authorization do
  defstruct role: nil, create: [], read: [], update: [], delete: []
  alias Noted.Schemas.{Team, TeamMembership, Invitation}
  alias __MODULE__

  def can(:admin = role) do
    grant(role)
    |> all(Team)
    |> all(TeamMembership)
    |> all(Invitation)
  end

  def can(:member = role) do
    grant(role)
    |> read(Team)
    |> read(TeamMembership)
  end

  def create?(authorization, resource), do: resource in authorization.create
  def read?(authorization, resource), do: resource in authorization.read
  def update?(authorization, resource), do: resource in authorization.update
  def delete?(authorization, resource), do: resource in authorization.delete

  defp grant(role) do
    %Authorization{role: role}
  end

  defp all(authorization, resource) do
    authorization
    |> create(resource)
    |> read(resource)
    |> update(resource)
    |> delete(resource)
  end

  defp create(authorization, resource), do: authorization |> allow_to(:create, resource)
  defp read(authorization, resource), do: authorization |> allow_to(:read, resource)
  defp update(authorization, resource), do: authorization |> allow_to(:update, resource)
  defp delete(authorization, resource), do: authorization |> allow_to(:delete, resource)

  defp allow_to(%Authorization{} = authorization, action, resource)
       when action in [:create, :read, :update, :delete] do
    allowed_resources = Map.get(authorization, action)
    updated_resources = [resource | allowed_resources]

    Map.put(authorization, action, updated_resources)
  end
end
