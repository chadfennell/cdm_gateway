defmodule CdmGatewayWeb.Api.V1.RecordsController do
  use CdmGatewayWeb, :controller
  require Logger

  alias CdmGateway.Record
  alias CdmGatewayWeb.Pagination
  alias CdmGatewayWeb.QueryBuilder

  @per_page 100

  def index(conn, params) do
    result =
      CdmGateway.Record
      |> QueryBuilder.filter_by_set_spec(params)
      |> Pagination.page(page(params), per_page: @per_page)

    render(conn, "index.json", records: result.records)
  end

  def page(params) do
    if params["page"] do
      String.to_integer(params["page"])
    else
      0
    end
  end

  def show(conn, %{"id" => id}) do
    record = CdmGateway.Record |> CdmGateway.Repo.get(id)
    render(conn, "show.json", record: record)
  end
end
