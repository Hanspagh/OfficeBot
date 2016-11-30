defmodule Officebot do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    slack_token = Application.get_env(:officebot, :token)
    # Define workers and child supervisors to be supervised
    children = [
      # Starts a worker by calling: Te.Worker.start_link(arg1, arg2, arg3)
      worker(Slack.Bot, [Officebot.Coffee, [], slack_token]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Officebot.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
