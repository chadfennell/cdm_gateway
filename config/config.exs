# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :cdm_gateway,
  ecto_repos: [CdmGateway.Repo]

# Configures the endpoint
config :cdm_gateway, CdmGatewayWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "A9FgWpsI/0CF+4W5NMO2AwOkdwC3xKB5byFG1ZtMJp6EuehlL+qQUGt0TcWitkcY",
  render_errors: [view: CdmGatewayWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: CdmGateway.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
