defmodule Mix.Tasks.CdmGateway.IngestSets do
  use Mix.Task
  require Logger

  # e.g. mix cdm_gateway.ingest_sets "http://cdm16022.contentdm.oclc.org" "https://server16022.contentdm.oclc.org/"
  @shortdoc "Ingest all sets from CONTENTdm"
  def run(args) do
    Mix.Task.run("app.start")

    CdmEtl.SetsIngest.run(
      oai_url: args |> Enum.at(0),
      cdm_api_url: args |> Enum.at(1)
    )
  end
end
