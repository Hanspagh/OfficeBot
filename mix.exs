defmodule Officebot.Mixfile do
  use Mix.Project

  def project do
    [app: :officebot,
    version: "0.1.0",
    elixir: "~> 1.3",
    build_embedded: Mix.env == :prod,
    start_permanent: Mix.env == :prod,
    deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: applications(Mix.env),
      mod: {Officebot, []}
    ]
  end

  defp applications(:dev), do: applications(:all) ++ [:remix]
  defp applications(_all), do: [:logger, :slack]
  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:slack, "~> 0.9.0"},
      {:remix, "~> 0.0.1", only: :dev},
    ]
  end
end
