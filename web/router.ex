defmodule ReviewMyCode.Router do
  use ReviewMyCode.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", ReviewMyCode do
    pipe_through :api
  end
end
