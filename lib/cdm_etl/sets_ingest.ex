defmodule CdmEtl.SetsIngest do
  alias CdmEtl.IngestLogger

  alias __MODULE__
  alias CdmEtl.Oai.Sets
  alias CdmEtl.Oai.IdentifierList
  alias CdmEtl.SetIngest

  defstruct([
    :oai_url,
    :cdm_api_url,
    caller: __MODULE__
  ])

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

  def run(args) do
    start(struct(%SetsIngest{}, args))
  end

  defp start(%SetsIngest{} = sets_ingest) do
    CdmApiPools.start(sets_ingest.cdm_api_url)

    Sets.set_specs(Sets.fetch(sets_ingest.oai_url))
    |> Enum.map(&[set_spec: &1])
    |> Enum.map(fn arg -> arg ++ [caller: sets_ingest.caller] end)
    |> Enum.map(
      &(&1 ++
          [
            identifier_list:
              IdentifierList.get(base_url: sets_ingest.oai_url, set_spec: &1[:set_spec])
          ])
    )
    |> Enum.map(&SetIngest.run(&1))
  end
end
