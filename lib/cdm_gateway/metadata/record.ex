defmodule CdmGateway.Metadata.Record do
  use Ecto.Schema
  import Ecto.Changeset

  schema "records" do
    field :cdm_id, :string
    field :is_deleted, :boolean, default: false
    field :is_primary, :boolean
    field :set_spec, :string
    field :parent_id, :integer
    field :cdm_modified, :naive_datetime
    field :metadata, :map

    timestamps()
  end

  @doc false
  def changeset(record, attrs) do
    record
    |> cast(attrs, [:metadata, :is_deleted, :parent_id, :last_modified])
    |> validate_required([:metadata, :is_deleted, :parent_id, :last_modified])
  end
end
