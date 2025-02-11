defmodule NotedWeb.Live.Notes.NewTeam do
  use NotedWeb, :live_view
  alias Noted.Contexts.Teams
  alias Noted.Schemas.Team

  def mount(_params, _session, socket) do
    form = Team.changeset(%Team{}) |> to_form()
    socket = assign(socket, form: form)

    {:ok, socket}
  end

  def handle_event("create_team", %{"team" => team_params}, socket) do
    user_id = socket.assigns.current_user.id

    case Teams.create_team(team_params, user_id) do
      {:ok, %{team: created_team}} ->
        socket =
          socket
          |> put_flash(:info, "Team #{created_team.name} created successfully!")
          |> push_navigate(to: "/app")

        {:noreply, socket}

      {:error, :team, %Ecto.Changeset{} = changeset, _} ->
        socket = assign(socket, form: changeset |> to_form)

        {:noreply, socket}

      {:error, _failed_operation, _failed_value, _changes_so_far} ->
        socket =
          socket
          |> put_flash(:error, "An unexpected error occurred")
          |> assign(form: Team.changeset(%Team{}) |> to_form)

        {:noreply, socket}
    end
  end

  def render(assigns) do
    ~H"""
    <.back navigate="/app">Go Back</.back>

    <h1>New Team</h1>

    <.form for={@form} phx-submit="create_team" class="max-w-48">
      <.input field={@form[:name]} label="Team Name" />
      <button phx-disable-with="Saving...">Save</button>
    </.form>
    """
  end
end
