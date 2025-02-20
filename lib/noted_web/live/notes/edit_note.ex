defmodule NotedWeb.Live.Notes.EditNote do
  use NotedWeb, :live_view
  alias Noted.Contexts.Notes
  alias Noted.Schemas.Note
  import Noted.Authorization

  def mount(%{"id" => note_id} = _params, _session, socket) do
    current_user = socket.assigns.current_user
    note = Notes.get_note!(note_id)

    if can(current_user) |> update?(note) do
      form = Note.changeset(note) |> to_form()

      {:ok, assign(socket, form: form)}
    else
      {:ok, push_navigate(socket, to: "/app/workspace")}
    end
  end

  def handle_event("update_note", %{"note" => note_params}, socket) do
    current_user = socket.assigns.current_user
    note_id = note_params["id"]
    note = Notes.get_note!(note_id)

    with true <- can(current_user) |> update?(note),
         {:ok, updated_note} <- Notes.update_note(note, note_params) do
      Phoenix.PubSub.broadcast(
        Noted.PubSub,
        "workspace:#{updated_note.team_id}",
        :update_team_workspace
      )

      socket =
        socket
        |> put_flash(:info, "Note updated successfully")
        |> push_navigate(to: "/app/workspace")

      {:noreply, socket}
    else
      false ->
        {:noreply, put_flash(socket, :error, "You are not allowed to perform this action")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: changeset |> to_form)}
    end
  end
end
