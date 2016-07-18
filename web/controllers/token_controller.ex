defmodule ReviewMyCode.TokenController do
  use ReviewMyCode.Web, :authenticated_controller

  def revoke(conn, _params, current_user, _claims) do
    if current_user do
      conn
      |> Guardian.Plug.current_token
      |> Guardian.revoke!
    end
    conn
    |> put_status(:no_content)
    |> json("")
  end
end
