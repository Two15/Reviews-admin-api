defmodule ReviewMyCode.OrganizationController do
  @moduledoc """
  Provides operations on Github organizations
  """
  use ReviewMyCode.Web, :authenticated_controller
  alias ReviewMyCode.User

  def index(conn, _, user, _claims) do
    %{:token => token} = user
    |> User.auth_for(:github)
    response = Tentacat.Client.new(%{access_token: token})
    |> Tentacat.Organizations.list_mine
    |> Enum.map(&scrub_org(&1))
    handle(conn, response)
  end

  defp scrub_org(org) do
    { uid, org } = Map.take(org, ["avatar_url", "login"])
    |> Map.get_and_update("login", fn(v)-> :pop end);
    Map.put(org, "uid", uid)
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
