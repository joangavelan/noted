defmodule NotedWeb.Components.User do
  use NotedWeb, :html

  attr :current_user, :map, required: true

  def welcome_user(assigns) do
    ~H"""
    <div>
      <div>
        <p>Hello {@current_user.name}!</p>
        <img src={@current_user.picture} alt="user picture" />
      </div>

      <form action="/logout" method="post">
        <input type="hidden" name="_csrf_token" value={Plug.CSRFProtection.get_csrf_token()} />
        <button>Logout</button>
      </form>
    </div>
    """
  end
end
