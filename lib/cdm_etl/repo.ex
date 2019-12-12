defmodule CdmEtl.Repo do
  use Ecto.Repo,
    otp_app: :cdm_etl,
    adapter: Ecto.Adapters.Postgres
end
