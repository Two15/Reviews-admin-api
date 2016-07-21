defmodule ReviewMyCode.Mixfile do
  use Mix.Project

  def project do
    [app: :reviewMyCode,
     version: "0.0.1",
     elixir: "~> 1.2",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases,
     deps: deps]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {ReviewMyCode, []},
     applications: applications(Mix.env)]
  end

  def applications(env) when env in [:test] do
    applications(:default) ++ [:ex_machina]
  end

  def applications(_) do
    [
      :cowboy,
      :ecto,
      :logger,
      :oauth2,
      :phoenix,
      :phoenix_ecto,
      :postgrex
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [{:phoenix, "~> 1.2.0"},
     {:corsica, "~> 0.4"},
     # was ecto 2.0.2
     {:ecto, github: "elixir-ecto/ecto", ref: "c89754c65678", override: true},
     {:ex_machina, "~>0.6", only: [:dev, :test]},
     {:oauth2, "~> 0.6"},
     {:guardian, "~> 0.12.0"},
     {:guardian_db, "~> 0.7"},
     {:phoenix_ecto, "~> 3.0"},
     {:postgrex, ">= 0.11.2", override: true},
     {:cowboy, "~> 1.0"}]
  end

  # Aliases are shortcut or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    ["ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
     "ecto.reset": ["ecto.drop", "ecto.setup"]]
  end
end
