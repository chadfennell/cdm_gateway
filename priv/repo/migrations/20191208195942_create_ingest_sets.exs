defmodule CdmGateway.Repo.Migrations.CreateIngestSets do
  use Ecto.Migration

  def change do
    create table("ingest_sets") do
      add :set_spec, :text
      add :record_count, :integer
      add :errors, :text
      add :ingest_run_id, references(:ingest_runs), null: false
      timestamps()
    end
  end
end
