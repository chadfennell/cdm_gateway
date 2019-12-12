defmodule CdmGatewayWeb.PageController do
  use CdmGatewayWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
