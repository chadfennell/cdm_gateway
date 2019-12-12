defmodule CdmGateway.Repo do
  use Ecto.Repo,
    otp_app: :cdm_gateway,
    adapter: Ecto.Adapters.Postgres
end
