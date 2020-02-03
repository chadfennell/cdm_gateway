defmodule SetIngestTest do
  require Logger
  use ExUnit.Case, async: true
  use Plug.Test
  # doctest CdmEtl
  require Ecto

  alias CdmEtl.Oai.IdentifierList

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(CdmGateway.Repo)
  end

  def callback(set_ingest) do
    case set_ingest.identifier_list.resumptionToken do
      "" ->
        raise "This shouldn't happen sice we have not recursed through the results"

      token ->
        assert token == "swede:200:swede:0000-00-00:9999-99-99:oai_dc"

        # A very basic sanity check to ensure records are getting persisted
        record = CdmGateway.Record |> CdmGateway.Repo.get_by(cdm_id: "swede/199")
        assert record.set_spec == "swede"
    end
  end

  @tag timeout: 2_000_000_000
  test "Tests ETL end-to-end" do
    CdmApiPools.start("https://server16022.contentdm.oclc.org/")

    args1 = [
      caller: __MODULE__,
      set_spec: "swede",
      identifier_list:
        IdentifierList.get(base_url: "http://cdm16022.contentdm.oclc.org", set_spec: "swede")
    ]

    CdmEtl.SetIngest.run(args1)
  end
end
