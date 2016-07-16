defmodule ReviewMyCode.Router do
  use ReviewMyCode.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  # This pipeline if intended for API requests and looks for the JWT in the "Authorization" header
  # In this case, it should be prefixed with "Bearer" so that it's looking for
  # Authorization: Bearer <jwt>
  pipeline :api_auth do
    plug Guardian.Plug.VerifyHeader, realm: "Bearer"
    plug Guardian.Plug.LoadResource
  end

  # This scope is the main authentication area for Ueberauth
  scope "/auth", ReviewMyCode do
    pipe_through [:api]

    get "/:identity", AuthController, :login
    get "/:identity/callback", AuthController, :callback
    post "/:identity/callback", AuthController, :callback
  end

  scope "/api", ReviewMyCode do
    pipe_through [:api, :api_auth]

    get "/", IndexController, :index
  end
end
