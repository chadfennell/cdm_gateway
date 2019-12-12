defmodule CdmEtl.Oai.IdentifierList do
  import SweetXml
  use GenServer

  @timeout 100_000

  # allows us to refer to our struct w/out the full
  # module path
  alias __MODULE__

  defstruct([
    :base_url,
    :set_spec,
    http_client: Tesla
  ])

  # Client

  def get(pid, resumptionToken \\ nil) do
    GenServer.call(pid, {:get, resumptionToken})
  end

  @doc """
  Start the Process
  """
  def start_link(args \\ []) do
    IO.puts("Starting Identifier List")
    GenServer.start_link(__MODULE__, struct(%IdentifierList{}, args))
  end

  @moduledoc """
  Converts an OAI ListSets response to an Elixir Map.
  """

  @doc """
  Convert and OAI ListSets response to an Elixir Map

  ## Examples
      iex> xml = ~s(<OAI-PMH xmlns="http://www.openarchives.org/OAI/2.0/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/ http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd">
      ...> <responseDate>2019-09-29T21:35:37Z</responseDate>
      ...> <request verb="ListIdentifiers" set="swede" metadataPrefix="oai_dc">http://cdm16022.contentdm.oclc.org/oai/oai.php</request>
      ...> <ListIdentifiers>
      ...> <header status="deleted">
      ...> <identifier>oai:cdm16022.contentdm.oclc.org:swede/2</identifier>
      ...> <datestamp>2012-02-08</datestamp>
      ...> <setSpec>swede</setSpec>
      ...> </header>
      ...> <header>
      ...> <identifier>oai:cdm16022.contentdm.oclc.org:swede/3</identifier>
      ...> <datestamp>2016-10-17</datestamp>
      ...> <setSpec>swede</setSpec>
      ...> </header>
      ...> <resumptionToken>swede:200:swede:0000-00-00:9999-99-99:oai_dc</resumptionToken>
      ...> </ListIdentifiers>
      ...> </OAI-PMH>)
      ...> CdmEtl.Oai.Identifier.Worker.to_map(xml)
      %{
          identifiers: [
            %{datestamp: "2012-02-08", identifier: "oai:cdm16022.contentdm.oclc.org:swede/2", setSpec: "swede", status: "deleted"},
            %{datestamp: "2016-10-17", identifier: "oai:cdm16022.contentdm.oclc.org:swede/3", setSpec: "swede", status: ""}
          ],
          resumptionToken: "swede:200:swede:0000-00-00:9999-99-99:oai_dc"
      }
  """
  def to_map(list_sets_xml) do
    list_sets_xml
    |> SweetXml.xmap(
      identifiers: [
        ~x"//header"l,
        identifier: ~x"./identifier/text()"s,
        status: ~x"./@status"s,
        datestamp: ~x"./datestamp/text()"s,
        setSpec: ~x"./setSpec/text()"s
      ],
      resumptionToken: ~x"//resumptionToken/text()"s
    )
    |> split_identifiers
  end

  defp split_identifiers(result) do
    Map.merge(result, %{
      deletables: deletables(result.identifiers),
      updatables: updatables(result.identifiers)
    })
  end

  defp updatables(identifiers) do
    identifiers
    |> Enum.filter(fn item -> item.status != "deleted" end)
    |> Enum.map(&to_id(&1.identifier))
  end

  defp deletables(identifiers) do
    identifiers
    |> Enum.filter(fn item -> item.status == "deleted" end)
    |> Enum.map(&to_id(&1.identifier))
  end

  defp to_id(identifier) do
    Enum.at(String.split(identifier, ":"), -1)
  end

  # Server (callbacks)

  @impl true
  def init(identifier_list) do
    {:ok, identifier_list}
  end

  @impl true
  def handle_call({:get, nil}, _from, identifier_list) do
    IO.puts("Requesting Initial batch if identifiers for set: #{identifier_list.set_spec}")
    {:reply, fetch(identifier_list), identifier_list}
  end

  @impl true
  def handle_call({:get, resumption_token}, _from, identifier_list) do
    IO.puts(
      "Requesting Initial batch if identifiers for set: #{identifier_list.set_spec} with token #{
        resumption_token
      }"
    )

    {:reply, fetch(identifier_list, resumption_token), identifier_list}
  end

  # Fetch the first result from an OAI endpoint
  defp fetch(%IdentifierList{} = identifier_list) do
    case CdmEtl.Request.fetch(
           [
             verb: "ListIdentifiers",
             metadataPrefix: "oai_dc",
             set: identifier_list.set_spec
           ],
           identifier_list.base_url,
           "/oai/oai.php",
           identifier_list.http_client
         ) do
      {:ok, response} -> response |> to_map
      {:timeout} -> {}
    end
  end

  # Fetch a batch of results following the first batch from and OAI endpoint
  defp fetch(%IdentifierList{} = identifier_list, resumption_token) do
    case CdmEtl.Request.fetch(
           [
             verb: "ListIdentifiers",
             resumptionToken: resumption_token
           ],
           identifier_list.base_url,
           "/oai/oai.php",
           identifier_list.http_client
         ) do
      {:ok, response} -> response |> to_map
      {:timeout} -> {}
    end
  end
end
