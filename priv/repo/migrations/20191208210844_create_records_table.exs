defmodule CdmGateway.Repo.Migrations.CreateRecordsTable do
  use Ecto.Migration

  def change do
    create table("records") do
      add :metadata, :map
      add :is_deleted, :boolean
      add :parent_id, :integer
      add :ingest_start, :naive_datetime
      add :ingest_run_id, references(:ingest_runs), null: false
      add :ingest_set_id, references(:ingest_sets), null: false
      timestamps()
    end
  end
end
