defmodule CdmGatewayWeb.Api.V1.RecordsView do
  use CdmGatewayWeb, :view
  require Logger

  def render("index.json", %{records: records}) do
    %{data: render_many(records, CdmGatewayWeb.Api.V1.RecordsView, "record.json")}
  end

  def render("show.json", %{record: record}) do
    %{data: render_one(record, __MODULE__, "record.json")}
  end

  def render("record.json", %{records: record}) do
    %{
      id: record.id,
      cdm_id: record.cdm_id,
      is_deleted: record.is_deleted,
      is_primary: record.is_primary,
      set_spec: record.set_spec,
      parent_id: record.parent_id,
      cdm_modified: record.cdm_modified,
      metadata: record.metadata
    }
  end
end
