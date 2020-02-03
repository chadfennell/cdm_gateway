defmodule CdmGateway.Record do
  use Ecto.Schema

  schema "records" do
    field :cdm_id, :string
    field :metadata, :map
    field :set_spec, :string
    field :is_deleted, :boolean
    field :is_primary, :boolean
    field :parent_id, :string
    field :cdm_modified, :naive_datetime

    timestamps()
  end
end
