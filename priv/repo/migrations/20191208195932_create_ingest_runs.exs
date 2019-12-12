defmodule CdmGateway.Repo.Migrations.CreateIngestRuns do
  use Ecto.Migration

  def change do
    create table("ingest_runs") do
      timestamps()
    end
  end
end
