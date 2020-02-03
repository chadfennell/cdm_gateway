defmodule CdmGateway.Repo.Migrations.CreateRecords do
  use Ecto.Migration

  def change do
    create table(:records) do
      add :cdm_id, :string
      add :is_deleted, :boolean, default: false, null: false
      add :is_primary, :boolean, default: true, null: false
      add :set_spec, :string
      add :parent_id, :string
      add :cdm_modified, :naive_datetime
      add :metadata, :map

      timestamps()
    end

    create(index(:records, [:set_spec]))
    create(unique_index(:records, [:cdm_id]))
    create(index(:records, [:parent_id]))
  end
end
