defmodule CdmEtl.Oai.Sets do
  import SweetXml
  use GenServer

  @moduledoc """
  Fetches OAI Sets and converts them into a list of maps
  """

  # Client

  @doc """
  Start the Process
  """
  def start_link(base_url, http_client \\ Tesla) do
    GenServer.start_link(__MODULE__, %{
      base_url: base_url,
      http_client: http_client
    })
  end

  @doc """
  Get a list of set data

  ## Examples
      iex> {:ok, pid} = CdmEtl.Oai.Sets.start_link("http://cdm16022.contentdm.oclc.org", OaiSetsHttpClient)
      ...> CdmEtl.Oai.Sets.get(pid)
      [%{description: "Description Here", name: "American Swedish Institute", setSpec: "swede"}]

  """
  def get(pid) do
    GenServer.call(pid, :get, 60_000)
  end

  @doc """
  Get a list of set_specs

  ## Examples
      iex> {:ok, pid} = CdmEtl.Oai.Sets.start_link("http://cdm16022.contentdm.oclc.org", OaiSetsHttpClient)
      ...> CdmEtl.Oai.Sets.set_specs(pid)
      ["swede"]

  """
  def set_specs(pid) do
    get(pid) |> Enum.map(&pluck(&1, :setSpec))
  end

  # Server (callbacks)

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_call(:get, _from, state) do
    {:reply, fetch(state[:base_url], state[:http_client]), state}
  end

  defp fetch(base_url, http_client) do
    CdmEtl.Request.fetch(
      [verb: "ListSets"],
      base_url,
      "/oai/oai.php",
      http_client
    )
    |> to_list
  end

  @doc """
  Convert and OAI ListSets response to an Elixir Map

  ## Examples
      iex> xml = ~s(<OAI-PMH xmlns="http://www.openarchives.org/OAI/2.0/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/ http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd">
      ...> <responseDate>2019-09-29T19:09:22Z</responseDate>
      ...> <request verb="ListSets">http://cdm16022.contentdm.oclc.org/oai/oai.php</request>
      ...> <ListSets>
      ...>  <set>
      ...>    <setSpec>swede</setSpec>
      ...>    <setName>American Swedish Institute</setName>
      ...>    <setDescription>
      ...>      <oai_dc:dc xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
      ...>        xmlns:dc="http://purl.org/dc/elements/1.1/"
      ...>        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd">
      ...>        <dc:description>The Description Here</dc:description>
      ...>      </oai_dc:dc>
      ...>    </setDescription>
      ...>  </set>
      ...> </ListSets>
      ...> </OAI-PMH>)
      ...> CdmEtl.Oai.Sets.to_list(xml)
      [%{name: "American Swedish Institute", setSpec: "swede", description: "The Description Here"}]
  """
  def to_list(list_sets_xml) do
    list_sets_xml
    |> SweetXml.xpath(
      ~x"//set"l,
      description: ~x"./setDescription/oai_dc:dc/dc:description/text()"s,
      name: ~x"./setName/text()"s,
      setSpec: ~x"./setSpec/text()"s
    )
  end

  defp pluck(value, key) do
    {:ok, content} = Map.fetch(value, key)
    content
  end
end
