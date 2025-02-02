defmodule NotedWeb.OAuth2Controller do
  use NotedWeb, :controller
  alias Noted.Contexts.Users
  require Logger

  def request(conn, %{"provider" => provider}) do
    case MultiProviderOAuth2.handle_request(provider) do
      {:ok, %{url: url, session_params: session_params}} ->
        conn
        |> put_session(:session_params, session_params)
        |> redirect(external: url)

      {:error, error} ->
        Logger.error("Authorization URL generation failed: #{inspect(error)}")

        conn
        |> put_flash(:error, "Authentication failed")
        |> redirect(to: "/login")
    end
  end

  def callback(conn, %{"provider" => provider} = params) do
    session_params = get_session(conn, :session_params)

    with {:ok, %{user: provider_user}} <-
           MultiProviderOAuth2.handle_callback(provider, params, session_params),
         {:ok, upserted_user} <-
           Users.upsert_user(%{
             name: provider_user["name"],
             email: provider_user["email"],
             picture: provider_user["picture"]
           }) do
      conn
      |> put_session(:user_id, upserted_user.id)
      |> put_flash(:info, "Sucessfully authenticated!")
      |> redirect(to: "/app")
    else
      {:error, error} ->
        Logger.error("Authorization callback failed: #{inspect(error)}")

        conn
        |> put_flash(:error, "Authentication failed")
        |> redirect(to: "/login")
    end
  end
end
