defmodule ReviewMyCode.RepositoryController do
  @moduledoc """
  Provides operations on Github repositories
  """
  use ReviewMyCode.Web, :authenticated_controller
  alias ReviewMyCode.User

  def index(conn, _, user, _claims) do
    token = user
    |> User.auth_for(:github)
    |> Map.get(:token)
    handle(conn, fetch_repos(token))
  end

  def index_org(conn, %{"org"=> org}, user, _claims) do
    %{:token => token, :uid => uid} = user
    |> User.auth_for(:github)
    response = case org do
      _ when org == uid -> fetch_repos(token)
      _ -> fetch_repos(token, org)
    end
    handle(conn, response)
  end

  defp fetch_repos(token) do
    Tentacat.Client.new(%{access_token: token})
    |> Tentacat.Repositories.list_mine()
    |> Enum.map(&scrub_repo(&1))
  end

  defp fetch_repos(token, org) do
    client = Tentacat.Client.new(%{access_token: token})
    Tentacat.Repositories.list_orgs(org, client)
    |> Enum.map(&scrub_repo(&1))
  end

  defp scrub_repo(org) do
    { %{ "avatar_url"=> avatar_url}, org } = Map.take(org, ["id", "owner", "full_name"])
    |> Map.get_and_update("owner", fn(v)-> :pop end);
    Map.put(org, "avatar_url", avatar_url)
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
