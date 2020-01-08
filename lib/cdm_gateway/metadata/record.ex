defmodule CdmGateway.Metadata.Record do
  use Ecto.Schema
  import Ecto.Changeset

  schema "records" do
    field :is_deleted, :boolean, default: false
    field :last_modified, :naive_datetime
    field :metadata, :map
    field :parent_id, :integer

    timestamps()
  end

  @doc false
  def changeset(record, attrs) do
    record
    |> cast(attrs, [:metadata, :is_deleted, :parent_id, :last_modified])
    |> validate_required([:metadata, :is_deleted, :parent_id, :last_modified])
  end
end
