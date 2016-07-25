defmodule ReviewMyCode.AuthController do
  @moduledoc """
  Handles the Überauth integration.
  This controller implements the request and callback phases for all providers.
  The actual creation and lookup of users/authorizations is handled by UserFromAuth
  """
  use ReviewMyCode.Web, :controller

  alias ReviewMyCode.UserFromAuth
  alias ReviewMyCode.OAuth

  def index(conn, _params) do
    conn
    |> redirect(external: OAuth.authorize_url!())
  end

  def callback(conn, %{"error" => error}) do
    conn
    # TODO Redirect to the app with a proper error message
    |> json(%{"errors": [error]})
  end

  def callback(conn, %{"code" => code}) do
    case OAuth.get_token!(code: code) do
      {:ok, token} ->
        auth = get_user!(token)
        payload = %{info: auth, uid: OAuth.uid(auth), provider: :github, token: token}
        signin(conn, payload)
      {:error, error} -> json(conn, %{"errors": [error]})
    end
  end

  defp get_user!(token) do
    # TODO Clearly insufficient...
    case OAuth2.AccessToken.get(token, "/user") do
     {:ok, %{body: user}} -> user
     {:error, %{reason: reason}} -> raise to_string(reason)
    end
  end

  defp signin(conn, payload) do
    case UserFromAuth.get_or_insert(payload, Repo) do
      {:ok, user} ->
        new_conn = Guardian.Plug.api_sign_in(conn, user, :token, perms: %{default: Guardian.Permissions.max})
        jwt = Guardian.Plug.current_token(new_conn)
        new_conn
        |> json(%{access_token: jwt, user: serialize_user(user, payload)})
      {:error, reason} ->
        conn
        |> json(%{"errors": [reason]})
    end
  end

  defp serialize_user(user, auth) do
    user = user
    |> Map.take([:name, :avatar_url])
    auth
    |> Map.take([:provider, :uid])
    |> Map.merge(user)
  end
end
