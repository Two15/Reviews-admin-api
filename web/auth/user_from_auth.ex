defmodule ReviewMyCode.UserFromAuth do
  @moduledoc """
  The JWT sent alongside the requests refer to an authorization.
  This authorization refers to a User.

  This module provides the necessary mechanism of making sure that
  with an authorization comes a user.
  """
  alias ReviewMyCode.User
  alias ReviewMyCode.Authorization

  def get_or_insert(%{uid: uid, provider: provider} = auth, repo) do
    case auth_and_validate(uid, provider, repo) do
      {:error, :not_found} -> register_user_from_auth(auth, repo)
      {:error, reason} -> {:error, reason}
      authorization ->
        user_from_authorization(authorization, repo)
    end
  end

  defp register_user_from_auth(auth, repo) do
    case repo.transaction(fn -> create_user_from_auth(auth, repo) end) do
      {:ok, response} -> response
      {:error, reason} -> {:error, reason}
    end
  end

  defp user_from_authorization(authorization, repo) do
    case repo.one(Ecto.assoc(authorization, :user)) do
      nil -> {:error, :user_not_found}
      user -> {:ok, user}
    end
  end

  defp create_user_from_auth(auth, repo) do
    email = Map.get(auth.info, "email")
    user = case repo.get_by(User, email: email) do
      nil -> create_user(auth, repo)
      user -> user
    end
    authorization_from_auth(user, auth, repo)
    {:ok, user}
  end

  defp create_user(%{"info": info}, repo) do
    name = name_from_auth(info)
    result = %User{}
    |> User.registration_changeset(scrub(%{email: Map.get(info, "email"), name: name}))
    |> repo.insert
    case result do
      {:ok, user} -> user
      {:error, reason} -> repo.rollback(reason)
    end
  end

  defp auth_and_validate(uid, provider, repo) do
    case repo.get_by(Authorization, uid: uid, provider: to_string(provider)) do
      nil -> {:error, :not_found}
      authorization ->
        if authorization.uid == uid do
          authorization
        else
          {:error, :uid_mismatch}
        end
    end
  end

  defp authorization_from_auth(user, auth, repo) do
    authorization = Ecto.build_assoc(user, :authorizations)
    result = authorization
    |> Authorization.changeset(
      scrub(
        %{
          provider: to_string(auth.provider),
          uid: auth.uid,
          token: auth.token.access_token
        }
      )
    )
    |> repo.insert

    case result do
      {:ok, the_auth} -> the_auth
      {:error, reason} -> repo.rollback(reason)
    end
  end

  defp name_from_auth(%{"name" => name}), do: name

  # We don't have any nested structures in our params that we are using scrub with so this is a very simple scrub
  defp scrub(params) do
    params
    |> Enum.filter(fn
      {_, val} when is_binary(val) -> String.strip(val) != ""
      {_, val} when is_nil(val) -> false
      _ -> true
    end)
    |> Enum.into(%{})
  end
end
