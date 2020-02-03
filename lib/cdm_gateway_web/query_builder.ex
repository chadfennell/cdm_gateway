defmodule CdmGatewayWeb.QueryBuilder do
  import Ecto.Query

  def filter_by_set_spec(query, params) do
    params["set_spec"]
    |> case do
      nil -> query
      "" -> query
      text -> query |> where(set_spec: ^text)
    end
  end
end
