# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :officebot,
  token: System.get_env("SLACK_TOKEN")

import_config "secret*.exs"
