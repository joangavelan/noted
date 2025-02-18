defmodule NotedWeb.Live.Notes.Workspace do
  use NotedWeb, :live_view
  alias Noted.Contexts.{Teams, Invitations}
  alias Noted.Schemas.{Team, Invitation, TeamMembership}
  import NotedWeb.Components.Notes
  import Noted.Authorization

  def mount(_params, %{"user_id" => user_id, "team_id" => team_id}, socket) do
    team_workspace = Teams.get_team_workspace!(team_id, user_id)

    socket =
      socket
      |> assign(
        team_workspace: team_workspace,
        search_query: "",
        search_results: []
      )

    Phoenix.PubSub.subscribe(Noted.PubSub, "workspace:#{team_workspace.id}")
    Phoenix.PubSub.subscribe(Noted.PubSub, "users:#{user_id}")

    {:ok, socket}
  end

  def mount(_params, _session, socket) do
    {:ok, redirect(socket, to: "/app")}
  end

  def handle_event("search_users", %{"query" => ""}, socket) do
    socket = assign(socket, search_results: [], search_query: "")

    {:noreply, socket}
  end

  def handle_event("search_users", %{"query" => query}, socket) do
    user_id = socket.assigns.current_user.id
    team_id = socket.assigns.team_workspace.id

    search_results = Teams.search_users_to_invite(query, user_id, team_id)

    socket = assign(socket, search_results: search_results, search_query: query)

    {:noreply, socket}
  end

  def handle_event("invite_user", %{"invited_user_id" => invited_user_id}, socket) do
    current_user = socket.assigns.current_user
    team_id = socket.assigns.team_workspace.id

    with true <- can(current_user.role) |> create?(Invitation),
         {:ok, invitation} <- Invitations.invite_user(invited_user_id, current_user.id, team_id) do
      Phoenix.PubSub.broadcast(
        Noted.PubSub,
        "users:#{invitation.invited_user_id}",
        :update_user_invitations
      )

      Phoenix.PubSub.broadcast(
        Noted.PubSub,
        "workspace:#{invitation.team_id}",
        :update_team_workspace
      )

      socket =
        socket
        |> put_flash(:info, "Invitation sent!")
        |> update(:team_workspace, fn t -> Teams.get_team_workspace!(t.id, current_user.id) end)
        |> assign(search_query: "", search_results: [])

      {:noreply, socket}
    else
      false ->
        {:noreply, put_flash(socket, :error, "You are not allowed to perform this action")}

      {:error, %Ecto.Changeset{errors: [invited_user_id: {"user already invited", _}]}} ->
        {:noreply, put_flash(socket, :error, "The user has already been invited")}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "An error occurred")}
    end
  end

  def handle_event("cancel_invitation", %{"invitation_id" => invitation_id}, socket) do
    user_id = socket.assigns.current_user.id

    case Invitations.decline_or_cancel_invitation(invitation_id) do
      {:ok, declined_or_canceled_invitation} ->
        Phoenix.PubSub.broadcast(
          Noted.PubSub,
          "users:#{declined_or_canceled_invitation.invited_user_id}",
          :update_user_invitations
        )

        Phoenix.PubSub.broadcast(
          Noted.PubSub,
          "workspace:#{declined_or_canceled_invitation.team_id}",
          :update_team_workspace
        )

        socket =
          update(socket, :team_workspace, fn t -> Teams.get_team_workspace!(t.id, user_id) end)

        {:noreply, socket}

      {:error, _changeset} ->
        socket = put_flash(socket, :error, "An unexpected error occurred")

        {:noreply, socket}
    end
  end

  def handle_event("remove_team_member", %{"membership_id" => membership_id}, socket) do
    current_user = socket.assigns.current_user

    with true <- can(current_user.role) |> delete?(TeamMembership),
         {:ok, removed_membership} <- Teams.remove_team_member(membership_id) do
      NotedWeb.Endpoint.broadcast(
        "users_socket:#{removed_membership.user_id}",
        "disconnect",
        %{}
      )

      Phoenix.PubSub.broadcast(
        Noted.PubSub,
        "workspace:#{removed_membership.team_id}",
        :update_team_workspace
      )

      socket =
        socket
        |> update(:team_workspace, fn tw -> Teams.get_team_workspace!(tw.id, current_user.id) end)
        |> put_flash(:info, "Member removed successfully!")

      {:noreply, socket}
    else
      false ->
        {:noreply, put_flash(socket, :error, "You are not allowed to perform this action")}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "An unexpected error occurred")}
    end
  end

  def handle_event("change_role", %{"membership_id" => membership_id, "role" => new_role}, socket) do
    current_user = socket.assigns.current_user

    with true <- can(current_user.role) |> update?(TeamMembership),
         {:ok, updated_membership} <- Teams.change_member_role(membership_id, new_role) do
      NotedWeb.Endpoint.broadcast(
        "users_socket:#{updated_membership.user_id}",
        "disconnect",
        %{}
      )

      socket =
        socket
        |> put_flash(:info, "User role updated successfully!")
        |> update(:team_workspace, fn tw -> Teams.get_team_workspace!(tw.id, current_user.id) end)

      {:noreply, socket}
    else
      false ->
        {:noreply, put_flash(socket, :error, "You are not allowed to perform this action")}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "An error occurred")}
    end
  end

  def handle_info(:update_team_workspace, socket) do
    user_id = socket.assigns.current_user.id

    socket =
      update(socket, :team_workspace, fn tw -> Teams.get_team_workspace!(tw.id, user_id) end)

    {:noreply, socket}
  end

  def handle_info({:force_team_logout, removed_team_id}, socket) do
    current_team_id = socket.assigns.team_workspace.id

    if current_team_id == removed_team_id do
      {:noreply, redirect(socket, to: "/team/logout")}
    else
      {:noreply, socket}
    end
  end
end
