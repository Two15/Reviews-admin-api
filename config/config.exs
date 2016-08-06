# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :reviewMyCode, ReviewMyCode.Endpoint,
  url: [host: "localhost"],
  root: Path.dirname(__DIR__),
  secret_key_base: "948Y/XtLTaGQDJ1I7Hq4wnNkIOgPupm3V3gW2ftteqTjYpzuay1YisJmKTYf3Hdp",
  render_errors: [accepts: ~w(json)],
  pubsub: [name: ReviewMyCode.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Configure phoenix generators
config :phoenix, :generators,
  migration: true,
  binary_id: false

config :reviewMyCode, ecto_repos: [ReviewMyCode.Repo]

config :guardian, Guardian,
  issuer: "ReviewMyCode.#{Mix.env}",
  ttl: {30, :days},
  verify_issuer: true,
  serializer: ReviewMyCode.GuardianSerializer,
  secret_key: to_string(System.get_env("GUARDIAN_SECRET")),
  hooks: GuardianDb,
  permissions: %{
    default: [
      :read_profile,
      :write_profile,
      :read_token,
      :revoke_token,
    ],
  }

config :oauth2, ReviewMyCode.OAuth,
  client_id: System.get_env("GITHUB_CLIENT_ID"),
  client_secret: System.get_env("GITHUB_CLIENT_SECRET"),
  redirect_uri: "http://localhost:4200/login/response",
  default_scope: "user:email,repo,write:repo_hook,notifications,read:org"

config :guardian_db, GuardianDb,
  repo: ReviewMyCode.Repo,
  sweep_interval: 60 # 60 minutes

config :reviewMyCode, :github,
  name: "web",
  active: true,
  events: [ "pull_request", "issue_comment", "issues"],
  config: %{
    content_type: "json",
    url: "http://localhost:8080",
    insecure_ssl: "1"
  }

config :reviewMyCode, :corsica,
  origins: "http://localhost:4200",
  allow_headers: ~w(accept authorization content-type)

config :exsentry, dsn: "" #An empty DSN disables ExSentry

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
