defmodule ReviewMyCode.Endpoint do
  use Phoenix.Endpoint, otp_app: :reviewMyCode

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Logger
  plug Corsica, origins: "http://localhost:4200", allow_headers: ~w(accept authorization)

  plug Plug.Parsers,
    parsers: [:json],
    pass: ["*/*"],
    json_decoder: Poison

  plug Plug.MethodOverride
  plug Plug.Head

  plug ReviewMyCode.Router
end
