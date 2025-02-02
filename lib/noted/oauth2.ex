defmodule MultiProviderOAuth2 do
  @spec handle_request(String.t()) :: {:ok, map()} | {:error, term()}
  def handle_request(provider) do
    {config, strategy_mod} = get_provider_info!(provider)
    strategy_mod.authorize_url(config)
  end

  @spec handle_callback(String.t(), map(), map()) :: {:ok, map()} | {:error, term()}
  def handle_callback(provider, params, session_params) do
    {config, strategy_mod} = get_provider_info!(provider)

    config
    |> Keyword.put(:session_params, session_params)
    |> strategy_mod.callback(params)
  end

  @spec get_provider_info!(String.t()) :: {keyword(), module()}
  defp get_provider_info!(provider_string) do
    provider_atom = String.to_existing_atom(provider_string)
    redirect_uri = "http://localhost:4000/oauth/#{provider_string}/callback"

    provider = Application.get_env(:noted, :oauth_providers) |> Keyword.fetch!(provider_atom)
    config = provider |> Keyword.get(:config) |> Keyword.put(:redirect_uri, redirect_uri)
    strategy_mod = Keyword.get(provider, :strategy_mod)

    {config, strategy_mod}
  end
end
