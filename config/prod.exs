use Mix.Config

# For production, we configure the host to read the PORT
# from the system environment. Therefore, you will need
# to set PORT=80 before running your server.
#
# You should also configure the url host to something
# meaningful, we use this information when generating URLs.
#
# Finally, we also include the path to a manifest
# containing the digested version of static files. This
# manifest is generated by the mix phoenix.digest task
# which you typically run after static files are built.
config :reviewMyCode, ReviewMyCode.Endpoint,
  http: [port: {:system, "PORT"}],
  url: [host: "api.review.two15.co", port: 443],
  force_ssl: [hsts: true, rewrite_on: [:x_forwarded_proto]],
  secret_key_base: System.get_env("SECRET_KEY_BASE")

# Do not print debug messages in production
config :logger, level: :info

# ## SSL Support
#
# To get SSL working, you will need to add the `https` key
# to the previous section and set your `:url` port to 443:
#
#     config :reviewMyCode, ReviewMyCode.Endpoint,
#       ...
#       url: [host: "example.com", port: 443],
#       https: [port: 443,
#               keyfile: System.get_env("SOME_APP_SSL_KEY_PATH"),
#               certfile: System.get_env("SOME_APP_SSL_CERT_PATH")]
#
# Where those two env variables return an absolute path to
# the key and cert in disk or a relative path inside priv,
# for example "priv/ssl/server.key".
#
# We also recommend setting `force_ssl`, ensuring no data is
# ever sent via http, always redirecting to https:
#
#     config :reviewMyCode, ReviewMyCode.Endpoint,
#       force_ssl: [hsts: true]
#
# Check `Plug.SSL` for all available options in `force_ssl`.

# ## Using releases
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start the server for all endpoints:
#
#     config :phoenix, :serve_endpoints, true
#
# Alternatively, you can configure exactly which server to
# start per endpoint:
#
#     config :reviewMyCode, ReviewMyCode.Endpoint, server: true
#

config :guardian, Guardian,
  issuer: "Two15 - ReviewMyCode",
  ttl: {1, :days}


# Configure your database
config :reviewMyCode, ReviewMyCode.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: System.get_env("DATABASE_URL"),
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "20"),
  ssl: true

config :oauth2, ReviewMyCode.OAuth,
  client_id: System.get_env("GITHUB_CLIENT_ID"),
  client_secret: System.get_env("GITHUB_CLIENT_SECRET"),
  redirect_uri: "https://admin.review.two15.co/login/response",
  default_scope: "user:email,repo,write:repo_hook,notifications,read:org"

config :reviewMyCode, :github,
  name: "web",
  active: true,
  events: [ "pull_request", "issue_comment", "issues"],
  config: %{
    content_type: "json",
    url: "https://pure-escarpment-50842.herokuapp.com",
    insecure_ssl: "0"
  }

config :reviewMyCode, :corsica,
  origins: "https://admin.review.two15.co",
  allow_headers: ~w(accept authorization content-type)

config :exsentry, dsn: System.get_env("SENTRY_DSN")
