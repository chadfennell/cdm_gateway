use Mix.Config

# Configure your database
config :cdm_gateway, CdmGateway.Repo,
  username: "postgres",
  password: "postgres",
  database: "cdm_gateway_test",
  hostname: "db",
  show_sensitive_data_on_connection_error: true,
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :cdm_gateway, CdmGatewayWeb.Endpoint,
  http: [port: 4002],
  server: false

# Original Logging config:
# Print only warnings and errors during test
# config :logger, level: :warn

# Custom Dev Logger Config:
config :logger,
  backends: [:console],
  format: "$time $metadata[$level] $message\n"
