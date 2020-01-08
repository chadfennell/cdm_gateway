defmodule SetIngestTest do
  require Logger
  use ExUnit.Case
  # doctest CdmEtl
  require Ecto

  @timeout 2_000_000

  @tag timeout: 200_000
  test "Tests ETL end-to-end" do
    callback = fn identifier_list, set_ingest ->
      case identifier_list.resumptionToken do
        "" ->
          Logger.info("+++++++++++++++++++DONE++++++++++++++++++++++++++++=")

        # <Re-Save Import Batch>

        token ->
          Logger.info(
            "Requesting Next Batch: +++++++++++++++++++++++++++++++++++++++++++++++++++++++ #{
              identifier_list.resumptionToken
            }"
          )

          # <New Import Batch Here>
          CdmEtl.SetIngest.next(%{set_ingest | resumption_token: token})
          |> Task.await(@timeout)
      end
    end

    CdmApiPools.start(
      "https://server16022.contentdm.oclc.org/",
      "http://cdm16022.contentdm.oclc.org"
    )

    # NaiveDateTime.utc_now()
    args = [
      # set_spec: "p16022coll416",
      callback: callback,
      set_spec: "swede"
    ]

    CdmEtl.SetIngest.start(args)
    |> Task.await(@timeout)
  end
end
