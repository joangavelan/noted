defmodule Noted.Authorization do
  @moduledoc """
  Provides authorization functionality for users based on their role.

  This module defines an `%Noted.Authorization{}` struct which requires a valid user and stores allowed operations for create, read, update, and delete actions.
  Each allowed operation is represented as a tuple `{resource_module, condition_function}`, where:

    - `resource_module` is always the module name of the given resource.
    - `condition_function` is a function (arity 1) that accepts the resource and returns a boolean.

  Public functions (`create?/2`, `read?/2`, `update?/2`, and `delete?/2`) determine if a
  given action is permitted on a resource.
  """

  defstruct user: nil, create: [], read: [], update: [], delete: []

  alias Noted.Schemas.{Team, TeamMembership, Invitation, Note}
  alias __MODULE__

  @doc """
  Builds an authorization struct for a user based on their role.

  Depending on the user's role, different permissions are assigned:

  - **Admin users (`role: :admin`)**:
      - Full CRUD permissions on Teams, TeamMemberships, and Invitations.
      - Create, read, and delete permissions on Notes.
      - Update permission on Notes is conditionally allowed if the note's
        `team_membership_id` matches the user's `membership_id`.

  - **Member users (`role: :member`)**:
      - Read permissions on Teams and TeamMemberships.
      - Create and read permissions on Notes.
      - Update and delete permissions on Notes are conditionally allowed
        if the note's `team_membership_id` matches the user's `membership_id`.

  ## Examples

      iex> import Noted.Authorization
      iex> alias Noted.Schemas.Note
      iex> user = %{role: :admin, membership_id: "123"}
      iex> note = %Note{
      ...>   description: "This is a note example",
      ...>   membership_id: "123"
      ...> }
      iex> can(user) |> create?(Note)
      true
      iex> can(user) |> create?(note)
      true

  ## Parameters

    - user: a map representing a user. The map must include a `:role` key and a `:membership_id`.

  ## Returns

    - An `%Noted.Authorization{}` struct with permissions configured for the given user.
  """
  def can(%{role: :admin} = user) do
    %Authorization{user: user}
    |> allow_crud(Team)
    |> allow_crud(TeamMembership)
    |> allow_crud(Invitation)
    |> allow(:create, Note)
    |> allow(:read, Note)
    |> allow(:update, Note, fn note -> note.team_membership_id == user.membership_id end)
    |> allow(:delete, Note)
  end

  def can(%{role: :member} = user) do
    %Authorization{user: user}
    |> allow(:read, Team)
    |> allow(:read, TeamMembership)
    |> allow(:create, Note)
    |> allow(:read, Note)
    |> allow(:update, Note, fn note -> note.team_membership_id == user.membership_id end)
    |> allow(:delete, Note, fn note -> note.team_membership_id == user.membership_id end)
  end

  @doc """
  Checks if the authorization allows creating the given resource.

  ## Parameters

    - auth: A `%Noted.Authorization{}` struct.
    - resource: The resource to check (either an atom or a struct).

  ## Returns

    - `true` if creation is allowed, `false` otherwise.
  """
  def create?(%Authorization{} = auth, resource), do: check_permission(auth, :create, resource)

  @doc """
  Checks if the authorization allows reading the given resource.

  ## Parameters

    - auth: A `%Noted.Authorization{}` struct.
    - resource: The resource to check (either an atom or a struct).

  ## Returns

    - `true` if reading is allowed, `false` otherwise.
  """
  def read?(%Authorization{} = auth, resource), do: check_permission(auth, :read, resource)

  @doc """
  Checks if the authorization allows updating the given resource.

  ## Parameters

    - auth: A `%Noted.Authorization{}` struct.
    - resource: The resource to check (either an atom or a struct).

  ## Returns

    - `true` if updating is allowed, `false` otherwise.
  """
  def update?(%Authorization{} = auth, resource), do: check_permission(auth, :update, resource)

  @doc """
  Checks if the authorization allows deleting the given resource.

  ## Parameters

    - auth: A `%Noted.Authorization{}` struct.
    - resource: The resource to check (either an atom or a struct).

  ## Returns

    - `true` if deletion is allowed, `false` otherwise.
  """
  def delete?(%Authorization{} = auth, resource), do: check_permission(auth, :delete, resource)

  # Checks if a user is allowed to perform an action on a resource.
  # The resource can be provided as a struct or as an atom representing the module (schema).
  # It retrieves the condition function for the action and resource.
  # If no condition is found, it means the action is not permitted.
  defp check_permission(%Authorization{} = auth, action, resource)
       when is_atom(resource) or is_map(resource) do
    resource_key = if is_atom(resource), do: resource, else: resource.__struct__
    action_permissions = Map.fetch!(auth, action)
    condition = Keyword.get(action_permissions, resource_key, false)
    condition && condition.(resource)
  end

  # Adds an allowed operation for a given action and resource.
  # The allowed operation is a tuple `{resource_module, condition_function}`.
  # The condition function is of arity 1 and takes the resource as input.
  # If no condition is provided, it defaults to a function that always returns `true`.
  defp allow(%Authorization{} = auth, action, resource, condition \\ fn _ -> true end)
       when is_function(condition, 1) do
    allowed_operations = Map.fetch!(auth, action)
    new_allowed_operation = {resource, condition}
    updated_allowed_operations = [new_allowed_operation | allowed_operations]
    Map.put(auth, action, updated_allowed_operations)
  end

  # Grants full CRUD permissions for a given resource by adding allowed operations
  # for the actions :create, :read, :update, and :delete.
  defp allow_crud(%Authorization{} = auth, resource) do
    auth
    |> allow(:create, resource)
    |> allow(:read, resource)
    |> allow(:update, resource)
    |> allow(:delete, resource)
  end
end
