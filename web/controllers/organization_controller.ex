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
    handle(conn, response)
  end

  defp handle(conn, {status, error}) do
    conn
    |> put_status(403)
    |> json(error)
  end

  defp handle(conn, response) do
    conn
    |> json(response)
  end
end
