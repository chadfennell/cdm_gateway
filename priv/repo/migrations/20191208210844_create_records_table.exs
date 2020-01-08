defmodule CdmGateway.Repo.Migrations.CreateRecords do
  use Ecto.Migration

  def change do
    create table(:records) do
      add :metadata, :map
      add :is_deleted, :boolean, default: false, null: false
      add :parent_id, :integer
      add :last_modified, :naive_datetime

      timestamps()
    end
  end
end
