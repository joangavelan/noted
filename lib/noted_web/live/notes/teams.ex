defmodule NotedWeb.Live.Notes.Teams do
  use NotedWeb, :live_view
  alias Noted.Contexts.{Teams, Invitations}
  import NotedWeb.Components.{Notes, User}

  def mount(_params, _session, socket) do
    user_id = socket.assigns.current_user.id
    teams = Teams.list_user_teams(user_id)
    invitations = Invitations.list_user_invitations(user_id)
    socket = assign(socket, teams: teams, invitations: invitations)

    {:ok, socket}
  end

  def handle_event("accept_invitation", %{"invitation_id" => invitation_id}, socket) do
    user_id = socket.assigns.current_user.id

    case Invitations.accept_invitation(invitation_id) do
      {:ok, _operation_results} ->
        socket =
          socket
          |> put_flash(:info, "Sucessfully joined the team!")
          |> update(:teams, fn _ -> Teams.list_user_teams(user_id) end)
          |> update(:invitations, fn _ -> Invitations.list_user_invitations(user_id) end)

        {:noreply, socket}

      {:error, _failed_operation, _failed_value, _changes_so_far} ->
        socket = put_flash(socket, :error, "An error occurred")

        {:noreply, socket}
    end
  end

  def handle_event("decline_invitation", %{"invitation_id" => invitation_id}, socket) do
    user_id = socket.assigns.current_user.id

    Invitations.decline_or_cancel_invitation!(invitation_id)

    socket = update(socket, :invitations, fn _ -> Invitations.list_user_invitations(user_id) end)

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Multi-Tenant Notes App</h1>

    <.welcome_user current_user={@current_user} />

    <hr />

    <h2>Teams</h2>

    <div>
      <ul :if={@teams != []} class="list">
        <li :for={team <- @teams}>
          <span>{team.name}</span>
          <form action="/teams/select" method="post" class="inline">
            <input type="hidden" name="_csrf_token" value={Plug.CSRFProtection.get_csrf_token()} />
            <input type="hidden" name="team_id" value={team.id} />
            <button phx-click={JS.show(to: "#loading-screen", display: "grid")} type="submit">
              {">"}
            </button>
          </form>
        </li>
      </ul>

      <p :if={@teams == []}>You don't belong to any team</p>
    </div>

    <.link navigate="/app/new-team">
      <button>Create Team</button>
    </.link>

    <hr />

    <h2>Invitations</h2>

    <ul :if={@invitations != []} class="list">
      <li :for={invitation <- @invitations}>
        <span>{invitation.team.name}</span>
        <button
          phx-click="accept_invitation"
          phx-value-invitation_id={invitation.id}
          phx-disable-with="Accepting..."
        >
          Accept
        </button>
        <button
          phx-click="decline_invitation"
          phx-value-invitation_id={invitation.id}
          phx-disable-with="Declining..."
        >
          Decline
        </button>
      </li>
    </ul>

    <.loading_screen message="Loading team workspace..." />
    """
  end
end
