defmodule NotedWeb.Live.Notes.Index do
  use NotedWeb, :live_view
  import NotedWeb.Components.User

  def render(assigns) do
    ~H"""
    <h1>Multi-Tenant Notes App</h1>

    <.welcome_user current_user={@current_user} />
    """
  end
end
