defmodule ReviewMyCode.OAuth do
  use OAuth2.Strategy

  # Public API

  def client do
    OAuth2.Client.new(Keyword.merge([
      strategy: __MODULE__,
      # client_id: "abc123",
      # client_secret: "abcdefg",
      # redirect_uri: "http://myapp.com/auth/callback",
      site: "https://api.github.com",
      authorize_url: "https://github.com/login/oauth/authorize",
      token_url: "https://github.com/login/oauth/access_token"
    ], Application.get_env(:oauth2, __MODULE__)))
  end

  def authorize_url!(params \\ []) do
    client()
    |> put_param(:scope, Keyword.get(Application.get_env(:oauth2, __MODULE__), :default_scope))
    |> OAuth2.Client.authorize_url!(params)
  end

  # you can pass options to the underlying http library via `options` parameter
  def get_token!(params \\ [], headers \\ [], options \\ []) do
    case OAuth2.Client.get_token(client(), params, headers, options) do
      { :ok, %{ access_token: nil, other_params: error } } -> {:error, error}
      { :ok, token } -> {:ok, token}
      { :error, error } -> {:error, error}
    end
  end

  # Strategy Callbacks

  def authorize_url(client, params) do
    OAuth2.Strategy.AuthCode.authorize_url(client, params)
  end

  def get_token(client, params, headers) do
    client
    |> put_header("Accept", "application/json")
    |> OAuth2.Strategy.AuthCode.get_token(params, headers)
  end

  def uid(%{ "login"=> login }), do: login

end
