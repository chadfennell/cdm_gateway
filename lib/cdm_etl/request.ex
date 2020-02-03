defmodule CdmEtl.Request do
  require Logger

  @retry_pause 20000

  # No more retries left
  def fetch(query, base_url, path, http_client, retry = 0) do
    logger(base_url, query, 0)
    {:error, :timeout}
  end

  @moduledoc """
  Fetches an OAI response
  """
  @doc """
  Fetch OAI content

  ## Examples

      iex> CdmEtl.Request.fetch(
      ...> [verb: "ListSets"],
      ...> "http://cdm16022.contentdm.oclc.org",
      ...> "/oai/oai.php",
      ...> OkReuestHttpClient)
      "some data here"

  """
  def fetch(query, base_url, path, http_client \\ Tesla, retry \\ 99) do
    logger(base_url, query, retry)

    case request(query, base_url, path, http_client) do
      {:ok, response} ->
        response.body

      {:error, :timeout} ->
        # Sleep for two seconds before another attempt
        :timer.sleep(@retry_pause)
        fetch(query, base_url, path, http_client, retry - 1)

      # The API has probably been swamped. Give it some time to recover.
      {:error, :socket_closed_remotely} ->
        :timer.sleep(@retry_pause)
        fetch(query, base_url, path, http_client, retry - 1)

      {:error, :econnrefused} ->
        raise "Connection Refused for #{base_url}"
    end
  end

  defp request(query, base_url, path, http_client \\ Tesla) do
    middleware = [
      {Tesla.Middleware.BaseUrl, base_url},
      {Tesla.Middleware.Query, query},
      {Tesla.Middleware.Timeout, timeout: 10_000}
    ]

    http_client.get(
      http_client.client(middleware),
      path
    )
  end

  defp logger(base_url, query, retry) do
    Logger.info(
      "Requesting OAI Identifiers: #{base_url} #{inspect(query)} (Retries Left: #{retry + 1})"
    )
  end
end
