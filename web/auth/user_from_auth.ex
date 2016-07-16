defmodule ReviewMyCode.UserFromAuth do
  alias ReviewMyCode.User
  alias ReviewMyCode.Authorization
  alias Ueberauth.Auth

  def get_or_insert(auth, current_user, repo) do
    case auth_and_validate(auth, repo) do
      {:error, :not_found} -> register_user_from_auth(auth, current_user, repo)
      {:error, reason} -> {:error, reason}
      authorization ->
        if authorization.expires_at && authorization.expires_at < Guardian.Utils.timestamp do
          replace_authorization(authorization, auth, current_user, repo)
        else
          user_from_authorization(authorization, current_user, repo)
        end
    end
  end

  defp register_user_from_auth(auth, current_user, repo) do
    case repo.transaction(fn -> create_user_from_auth(auth, current_user, repo) end) do
      {:ok, response} -> response
      {:error, reason} -> {:error, reason}
    end
  end

  defp replace_authorization(authorization, auth, current_user, repo) do
    case user_from_authorization(authorization, current_user, repo) do
      {:ok, user} ->
        case repo.transaction(fn ->
          repo.delete(authorization)
          authorization_from_auth(user, auth, repo)
          user
        end) do
          {:ok, user} -> {:ok, user}
          {:error, reason} -> {:error, reason}
        end
      {:error, reason} -> {:error, reason}
    end
  end

  defp user_from_authorization(authorization, current_user, repo) do
    case repo.one(Ecto.assoc(authorization, :user)) do
      nil -> {:error, :user_not_found}
      user ->
        if current_user && current_user.id != user.id do
          {:error, :user_does_not_match}
        else
          {:ok, user}
        end
    end
  end

  defp create_user_from_auth(auth, current_user, repo) do
    user = current_user
    if !user, do: user = repo.get_by(User, email: auth.info.email)
    if !user, do: user = create_user(auth, repo)
    authorization_from_auth(user, auth, repo)
    {:ok, user}
  end

  defp create_user(auth, repo) do
    name = name_from_auth(auth)
    result = User.registration_changeset(%User{}, scrub(%{email: auth.info.email, name: name}))
    |> repo.insert
    case result do
      {:ok, user} -> user
      {:error, reason} -> repo.rollback(reason)
    end
  end

  defp auth_and_validate(%{provider: service} = auth, repo)  when service in [:google, :facebook, :github] do
    case repo.get_by(Authorization, uid: auth.uid, provider: to_string(auth.provider)) do
      nil -> {:error, :not_found}
      authorization ->
        if authorization.uid == auth.uid do
          authorization
        else
          {:error, :uid_mismatch}
        end
    end
  end

  defp auth_and_validate(auth, repo) do
    case repo.get_by(Authorization, uid: auth.uid, provider: to_string(auth.provider)) do
      nil -> {:error, :not_found}
      authorization ->
        if authorization.token == auth.credentials.token do
          authorization
        else
          {:error, :token_mismatch}
        end
    end
  end

  defp authorization_from_auth(user, auth, repo) do
    authorization = Ecto.build_assoc(user, :authorizations)
    result = Authorization.changeset(
      authorization,
      scrub(
        %{
          provider: to_string(auth.provider),
          uid: auth.uid,
          token: auth.credentials.token,
          refresh_token: auth.credentials.refresh_token,
          expires_at: auth.credentials.expires_at
        }
      )
    ) |> repo.insert

    case result do
      {:ok, the_auth} -> the_auth
      {:error, reason} -> repo.rollback(reason)
    end
  end

  defp name_from_auth(auth) do
    if auth.info.name do
      auth.info.name
    else
      [auth.info.first_name, auth.info.last_name]
      |> Enum.filter(&(&1 != nil and String.strip(&1) != ""))
      |> Enum.join(" ")
    end
  end

  # We don't have any nested structures in our params that we are using scrub with so this is a very simple scrub
  defp scrub(params) do
    result = Enum.filter(params, fn
      {key, val} when is_binary(val) -> String.strip(val) != ""
      {key, val} when is_nil(val) -> false
      _ -> true
    end)
    |> Enum.into(%{})
    result
  end
end
