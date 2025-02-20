defmodule NotedWeb.Live.Notes.CreateNote do
  use NotedWeb, :live_view
  alias Noted.Contexts.Notes
  alias Noted.Schemas.Note

  def mount(_params, %{"team_id" => team_id}, socket) do
    form = Note.changeset(%Note{}) |> to_form()

    {:ok, assign(socket, team_id: team_id, form: form)}
  end

  def handle_event("create_note", %{"note" => note_params}, socket) do
    current_user = socket.assigns.current_user
    team_id = socket.assigns.team_id

    case Notes.create_note(current_user.membership_id, team_id, note_params) do
      {:ok, _created_note} ->
        Phoenix.PubSub.broadcast(Noted.PubSub, "workspace:#{team_id}", :update_team_workspace)

        socket =
          socket
          |> put_flash(:info, "Note created successfully")
          |> push_navigate(to: "/app/workspace")

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: changeset |> to_form)}
    end
  end
end
