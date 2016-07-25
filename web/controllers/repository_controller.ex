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
    response = Tentacat.Client.new(%{access_token: token})
    |> Tentacat.Organizations.list_mine
    handle(conn, response)
  end

  defp handle(conn, {status, error}) do
    conn
    |> send_resp(403 , error)
  end

  defp handle(conn, response) do
    conn
    |> json(response)
  end

end
