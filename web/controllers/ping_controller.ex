defmodule ReviewMyCode.PingController do
  use ReviewMyCode.Web, :authenticated_controller

  def ping(conn, _, user, _), do: ping(conn, user)

  defp ping(conn, user) do
    conn
    |>json(%{status: status(user)})
  end

  defp status(nil), do: "unauthenticated"
  defp status(_), do: "authenticated"
end
