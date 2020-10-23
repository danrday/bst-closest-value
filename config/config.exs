# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :bst_closest_value,
  ecto_repos: [BstClosestValue.Repo]

# Configures the endpoint
config :bst_closest_value, BstClosestValueWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "arhCb2g/ZJiqF/qLKNYEAPMvHhyl5IN8Uk8ePjGTxWUiVGfMbfvWK+SUu/T6nWL4",
  render_errors: [view: BstClosestValueWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: BstClosestValue.PubSub,
  live_view: [signing_salt: "Ia1CsLJy"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
