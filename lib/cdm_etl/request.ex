defmodule CdmEtl.Request do
  require Logger

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
      {:ok, "some data here"}

  """
  def fetch(query, base_url, path, http_client \\ Tesla, retry \\ 4) do
    logger(base_url, query, retry)

    case request(query, base_url, path, http_client) do
      {:ok, response} ->
        {:ok, response.body}

      {:error, :timeout} ->
        # Sleep for two seconds before another attempt
        :timer.sleep(1000)
        fetch(query, base_url, path, http_client, retry - 1)

      {:error, :econnrefused} ->
        raise "Connection Refused for #{base_url}"
    end
  end

  def request(query, base_url, path, http_client \\ Tesla) do
    middleware = [
      {Tesla.Middleware.BaseUrl, base_url},
      {Tesla.Middleware.Query, query},
      {Tesla.Middleware.Timeout, timeout: 5_000}
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
