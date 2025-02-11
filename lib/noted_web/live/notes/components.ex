defmodule NotedWeb.Components.Notes do
  use NotedWeb, :html

  attr :message, :string, required: true

  def loading_screen(assigns) do
    ~H"""
    <div
      id="loading-screen"
      class="fixed hidden inset-0 z-50 bg-white grid place-items-center pointer-events-none"
    >
      {@message}
    </div>
    """
  end

  attr :search_query, :string, required: true
  attr :search_results, :list, required: true

  def search_users_to_invite_box(assigns) do
    ~H"""
    <div id="search-box" class="relative max-w-80">
      <form id="search-bar-form" phx-change="search_users">
        <input
          id="search-bar"
          name="query"
          type="text"
          placeholder="Search users..."
          class="w-full"
          phx-debounce="300"
          value={@search_query}
          autocomplete="off"
        />
      </form>

      <div :if={@search_query != ""} id="search-results" class="absolute left-0 top-12 w-full border">
        <ul :if={@search_results != []} class="bg-white">
          <li :for={user <- @search_results} class="flex items-center justify-between p-2">
            <div class="flex gap-2 items-center">
              <img src={user.picture} class="size-10 rounded-full" />
              <span>{user.name}</span>
            </div>
            <button
              :if={!user.is_team_member}
              phx-click="invite_user"
              phx-value-invited_user_id={user.id}
              phx-disable-with="Inviting..."
            >
              Invite
            </button>

            <button :if={user.is_team_member} class="border-green-200">
              {user.role}
            </button>
          </li>
        </ul>

        <p :if={@search_results == []} class="bg-white p-2">No results for this query</p>
      </div>
    </div>
    """
  end
end
