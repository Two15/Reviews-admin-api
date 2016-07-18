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
    plug Guardian.Plug.EnsureAuthenticated
  end

  pipeline :api_public do
    plug Guardian.Plug.EnsureNotAuthenticated
  end

  scope "/", ReviewMyCode do
    pipe_through [:api]

    get "/", PingController, :ping
  end

  scope "/auth", ReviewMyCode do
    pipe_through [:api, :api_public]

    get "/", AuthController, :index
    get "/token", AuthController, :callback
  end

  scope "/auth/logout", ReviewMyCode do
    pipe_through [:api, :api_auth]

    delete "/", TokenController, :revoke
  end

  scope "/api", ReviewMyCode do
    pipe_through [:api, :api_auth]

    get "/", PingController, :ping
  end
end
