defmodule ReviewMyCode.RepositoryController do
  @moduledoc """
  Provides operations on Github repositories
  """
  use ReviewMyCode.Web, :authenticated_controller
  alias ReviewMyCode.User
  alias ReviewMyCode.Repository

  def index(conn, _, user, _claims) do
    token = user
    |> User.auth_for(:github)
    |> Map.get(:token)
    handle(conn, fetch_repos(token))
  end

  def status(conn, %{"owner"=> owner, "name"=> name}, _user, _claims) do
    ref = %{ owner: owner, name: name, provider: "github" }
    value = case Repository.find_by_reference(ref, Repo) do
      nil -> false
      repo -> repo.enabled
    end
    conn
    |> json(%{enabled: value})
  end

  def create_webhook(conn, %{"name"=> name, "owner"=> owner, "provider"=> provider}, user, _claims) do
    update_webhook(conn, user, name, owner, provider, true)
  end

  def delete_webhook(conn, %{"name"=> name, "owner"=> owner, "provider"=> provider}, user, _claims) do
    update_webhook(conn, user, name, owner, provider, false)
  end

  defp update_webhook(conn, user, name, owner, provider, enabled) do
    token = User.token_for(user, provider)

    ref = %{ owner: owner, name: name, provider: provider }
    changeset = case Repository.find_by_reference(ref, Repo) do
      nil -> %Repository{ id: Ecto.UUID.generate }
      repo -> repo
    end
    |> Repository.changeset(Map.merge(ref, %{enabled: enabled}))

    webhook = case changeset.data.webhook_id do
      nil -> create_github_webhook(token, changeset.data.id, ref, enabled)
      id -> update_github_webhook(token, id, changeset.data.id, ref, enabled)
    end
    webhook_id = case webhook do
      %{"id"=> webhook_id} -> {:ok, to_string(webhook_id)}
      {201, %{"id"=> webhook_id}} -> {:ok, to_string(webhook_id)}
      {422, reason} -> {:error, %{errors: [%{status: 422, title: "Could not create webhook", meta: reason}]}}
    end
    result = case webhook_id do
      {:ok, id} ->
        changeset
        |> Ecto.Changeset.cast(%{webhook_id: id}, [:webhook_id])
        |> Repo.insert_or_update
      any -> any
    end
    case result do
      {:ok, repo} ->
        conn |> json(%{ enabled: repo.enabled })
      {:error, msg} -> conn |> put_status(400) |> json(msg)
      _ -> conn |> send_resp(500, "Unknown error")
    end
  end

  defp create_github_webhook(token, secret, repo, enabled) do
    client = Tentacat.Client.new(%{access_token: token})
    config = Application.fetch_env!(:reviewMyCode, String.to_atom(repo.provider))
    |> Enum.into(%{})
    |> Map.merge(%{active: enabled})
    config = Map.put(config, "config", Map.put(config.config, "secret", secret))
    Tentacat.Hooks.create(repo.owner, repo.name, config, client)
  end

  defp update_github_webhook(token, id, secret, repo, enabled) do
    client = Tentacat.Client.new(%{access_token: token})
    config = Application.fetch_env!(:reviewMyCode, String.to_atom(repo.provider))
    |> Enum.into(%{})
    |> Map.merge(%{active: enabled})
    config = Map.put(config, "config", Map.put(config.config, "secret", secret))

    # Create token if it has been deleted from Github
    case Tentacat.Hooks.update(repo.owner, repo.name, id, config, client) do
      {404, _} -> create_github_webhook(token, secret, repo, enabled)
      any -> any
    end
  end

  defp fetch_repos(token) do
    Tentacat.Client.new(%{access_token: token})
    |> Tentacat.Repositories.list_mine()
    |> Enum.map(&scrub_repo(&1))
  end

  defp scrub_repo(org) do
    { %{ "login"=> login, "avatar_url"=> avatar_url}, org } = Map.take(org, ["id", "owner", "full_name", "name"])
    |> Map.get_and_update("owner", fn(_)-> :pop end);
    Map.put(org, "avatar_url", avatar_url)
    |> Map.put("owner", login)
  end

  defp handle(conn, {_status, error}) do
    conn
    |> put_status(403)
    |> json(error)
  end

  defp handle(conn, response) do
    conn
    |> json(response)
  end

end
