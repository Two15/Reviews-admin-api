defmodule ReviewMyCode.PingController do
  use ReviewMyCode.Web, :controller

  def ping(conn, _params, user, _claims) do
    conn
    |>json(%{status: status(user)})
  end

  defp status(nil), do: "unauthenticated"
  defp status(_), do: "authenticated"
end

