defmodule ReviewMyCode do
  @moduledoc false
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ReviewMyCode.Supervisor]
    Supervisor.start_link(children(Mix.env), opts)
    Logger.add_backend(ExSentry.LoggerBackend)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    ReviewMyCode.Endpoint.config_change(changed, removed)
    :ok
  end

  def children(env) when env != "test" do
    import Supervisor.Spec, warn: false
    children ++ [worker(GuardianDb.ExpiredSweeper, [])]
  end

  def children do
    import Supervisor.Spec, warn: false

    [
      # Start the endpoint when the application starts
      supervisor(ReviewMyCode.Endpoint, []),
      # Start the Ecto repository
      worker(ReviewMyCode.Repo, []),

      # Here you could define other workers and supervisors as children
      # worker(ReviewMyCode.Worker, [arg1, arg2, arg3]),
    ]
  end
end
