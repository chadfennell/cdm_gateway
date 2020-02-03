defmodule CdmGatewayWeb.Api.V1.RecordsController do
  use CdmGatewayWeb, :controller
  require Logger

  alias CdmGateway.Record
  alias CdmGatewayWeb.Pagination

  @per_page 100

  def index(conn, %{"page" => page}) do
    result =
      CdmGateway.Record
      |> Pagination.page(String.to_integer(page), per_page: @per_page)

    render(conn, "index.json", records: result.records)
  end

  def index(conn, _params) do
    result =
      CdmGateway.Record
      |> Pagination.page(0, per_page: @per_page)

    render(conn, "index.json", records: result.records)
  end

  def show(conn, %{"id" => id}) do
    record = CdmGateway.Record |> CdmGateway.Repo.get(id)
    render(conn, "show.json", record: record)
  end
end
