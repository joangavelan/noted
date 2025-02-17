defmodule NotedWeb.LiveHooks.RequireAuth do
  alias Noted.Contexts.{Users, Teams}
  import Phoenix.LiveView
  import Phoenix.Component

  def on_mount(:default, _params, %{"user_id" => user_id} = _session, socket) do
    {:cont, assign_new(socket, :current_user, fn -> Users.get_user!(user_id) end)}
  end

  def on_mount(:default, _params, _sessions, socket) do
    {:halt, redirect(socket, to: "/login")}
  end

  def on_mount(
        :ensure_is_team_member,
        _params,
        %{"user_id" => user_id, "team_id" => team_id} = _session,
        socket
      ) do
    case Teams.get_team_member(user_id, team_id) do
      nil ->
        # Redirect to /team/logout controller to clean up the session from the controller action
        {:halt, redirect(socket, to: "/team/logout")}

      team_member ->
        {:cont, update(socket, :current_user, fn _ -> team_member end)}
    end
  end

  def on_mount(:ensure_is_team_member, _params, _session, socket) do
    {:halt, redirect(socket, to: "/team/logout")}
  end
end
