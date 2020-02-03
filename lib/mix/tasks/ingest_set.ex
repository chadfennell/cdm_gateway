defmodule Mix.Tasks.CdmGateway.IngestSet do
  use Mix.Task
  require Logger

  alias CdmEtl.Oai.IdentifierList
  alias CdmEtl.SetIngest
  alias CdmEtl.IngestLogger

  def callback(set_ingest) do
    case set_ingest.identifier_list.resumptionToken do
      "" ->
        IngestLogger.info("completed.log", set_ingest.set_spec)

      token ->
        IngestLogger.info("batch.log", token)

        args = [
          caller: set_ingest.caller,
          set_spec: set_ingest.set_spec,
          identifier_list:
            IdentifierList.get(
              base_url: set_ingest.identifier_list.base_url,
              resumption_token: token
            )
        ]

        SetIngest.run(args)
    end
  end

  @shortdoc "Ingest a collection set from CONTENTdm"
  def run(args) do
    Mix.Task.run("app.start")
    set_spec = args |> Enum.at(0)
    oai_url = args |> Enum.at(1)
    cdm_url = args |> Enum.at(2)

    CdmApiPools.start(cdm_url)

    args = [
      caller: __MODULE__,
      set_spec: set_spec,
      identifier_list: IdentifierList.get(base_url: oai_url, set_spec: set_spec)
    ]

    SetIngest.run(args)
  end
end
