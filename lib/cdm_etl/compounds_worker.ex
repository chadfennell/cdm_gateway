defmodule CdmEtl.CdmApi.Compounds.Worker do
  use GenServer

  @moduledoc """
  Fetches and parses the compound info for a CONTENTdm Item
  """

  alias __MODULE__

  defstruct([
    :base_url,
    http_client: Tesla
  ])

  @timeout 100_000

  def run(id, callback) do
    Task.async(fn ->
      :poolboy.transaction(
        :compounds_worker,
        fn pid -> callback.(GenServer.call(pid, {:get, id}, @timeout)) end,
        @timeout
      )
    end)
  end

  @doc """
  Start the Process
  """
  def start_link(args \\ []) do
    IO.puts("Starting CDM Item Request Worker")
    GenServer.start_link(__MODULE__, struct(%Worker{}, args))
  end

  @impl true
  def init(worker) do
    {:ok, worker}
  end

  @impl true
  def handle_call({:get, id}, _from, worker) do
    IO.puts("Requesting CDM Item: #{id}")
    {:reply, fetch(id, worker), worker}
  end

  def get(pid, id) do
    GenServer.call(pid, {:get, id})
  end

  @doc """
  Fetch Compound info from the CONTENTdm API

  ## Examples

      iex> CdmEtl.CdmApi.CompoundInfo.fetch("p16022coll416/904", "https://server16022.contentdm.oclc.org")
      "<xml>...."

  """
  def fetch(id, worker) do
    case CdmEtl.Request.fetch(
           [q: "dmGetCompoundObjectInfo/#{id}/json"],
           worker.base_url,
           "/dmwebservices/index.php",
           worker.http_client
         ) do
      {:ok, response} ->
        response
        |> (&to_map(&1)).()
        |> (&to_ids(&1, id)).()

      {:timeout} ->
        {}
    end
  end

  @doc """
  Convert a CONTENTdm Compound Info response into a map

  ## Examples
      iex> compound_info = ~s({
      ...> "type": "Document",
      ...> "page": [
      ...> {
      ...> "pagetitle": "Page 1",
      ...> "pagefile": "815.jp2",
      ...> "pageptr": "814"
      ...> },
      ...> {
      ...> "pagetitle": "Page 2",
      ...> "pagefile": "816.jp2",
      ...> "pageptr": "815"
      ...> }
      ...> ]
      ...> })
      ...> CdmEtl.CdmApi.CompoundInfo.parse(compound_info)
      [%{"pagefile" => "815.jp2", "pageptr" => "814", "pagetitle" => "Page 1"}, %{"pagefile" => "816.jp2", "pageptr" => "815", "pagetitle" => "Page 2"}]
  """
  def to_map(compound_info) do
    Jason.decode!(compound_info)
  end

  defp to_ids(compound, id) do
    compound["page"]
    |> Enum.map(& &1["pageptr"])
    |> Enum.map(&"#{extract_collection(id)}/#{&1}")

    # case compound["pageptr"] do
    #   "" -> {}
    #   id -> "#{extract_collection(id)}/#{id}"
    # end
    # "#{extract_collection(id)}/#{compound["pageptr"]}"
  end

  defp extract_collection(id) do
    Enum.join(Enum.take(String.split(id, "/"), 1))
  end

  defp extract_page(response)
       when response == %{"code" => "-2", "message" => "Requested item is not compound"},
       do: []

  defp extract_page(response), do: response["page"]

  # Page comes back in some funky formats, gaurd against returning inconsistent data
  defp sanitize(page) when is_map(page), do: [page]
  defp sanitize(page) when is_bitstring(page), do: []
  defp sanitize(page) when is_nil(page), do: []
  defp sanitize(page), do: page
end
