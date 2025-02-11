defmodule NotedWeb.Live.Notes.Workspace do
  use NotedWeb, :live_view
  alias Noted.Contexts.{Teams, Invitations}
  import NotedWeb.Components.Notes

  def mount(_params, %{"team_id" => team_id}, socket) do
    user_id = socket.assigns.current_user.id
    team_workspace = Teams.get_team_workspace!(team_id, user_id)

    socket =
      socket
      |> assign(
        team_workspace: team_workspace,
        search_query: "",
        search_results: []
      )

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
    current_user_id = socket.assigns.current_user.id
    team_id = socket.assigns.team_workspace.id

    case Invitations.invite_user(invited_user_id, current_user_id, team_id) do
      {:ok, _invitation} ->
        socket =
          socket
          |> put_flash(:info, "Invitation sent!")
          |> update(:team_workspace, fn t -> Teams.get_team_workspace!(t.id, current_user_id) end)
          |> assign(search_query: "", search_results: [])

        {:noreply, socket}

      {:error, %Ecto.Changeset{errors: [invited_user_id: {"user already invited", _}]}} ->
        {:noreply, put_flash(socket, :error, "The user has already been invited")}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "An error occurred")}
    end
  end

  def handle_event("cancel_invitation", %{"invitation_id" => invitation_id}, socket) do
    user_id = socket.assigns.current_user.id

    Invitations.decline_or_cancel_invitation!(invitation_id)

    socket =
      update(socket, :team_workspace, fn t -> Teams.get_team_workspace!(t.id, user_id) end)

    {:noreply, socket}
  end

  def handle_event("remove_team_member", %{"membership_id" => membership_id}, socket) do
    user_id = socket.assigns.current_user.id

    Teams.remove_team_member!(membership_id)

    socket =
      socket
      |> update(:team_workspace, fn t -> Teams.get_team_workspace!(t.id, user_id) end)
      |> put_flash(:info, "Member removed successfully!")

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <.back navigate="/app">Go Back</.back>

    <h1>{@team_workspace.name} workspace</h1>

    <hr />

    <div>
      <h2>Members</h2>
      <ul class="list">
        <li :for={team_membership <- @team_workspace.team_memberships}>
          <span>{team_membership.user.name} - {team_membership.role}</span>

          <button
            :if={team_membership.user_id != @current_user.id}
            phx-click="remove_team_member"
            phx-value-membership_id={team_membership.id}
            phx-disable-with="Removing..."
          >
            Remove
          </button>
        </li>
      </ul>
    </div>

    <hr />

    <div>
      <h2>Invite Users</h2>

      <.search_users_to_invite_box search_query={@search_query} search_results={@search_results} />

      <hr />

      <h2>Invitations Sent</h2>

      <ul :if={@team_workspace.invitations != []}>
        <li :for={invitation <- @team_workspace.invitations} class="flex gap-4">
          <div class="flex gap-1.5">
            <span>{invitation.invited_user.name}</span>
          </div>
          <button
            phx-click="cancel_invitation"
            phx-value-invitation_id={invitation.id}
            phx-disable-with="Canceling..."
          >
            Cancel
          </button>
        </li>
      </ul>
    </div>
    """
  end
end
