defmodule SetIngestTest do
  require Logger
  use ExUnit.Case
  # doctest CdmEtl
  require Ecto

  @tag timeout: 200_000
  test "Tests ETL end-to-end" do
    CdmApiPools.start(
      "https://server16022.contentdm.oclc.org/",
      "http://cdm16022.contentdm.oclc.org"
    )

    args = [
      set_spec: "p16022coll416",
      ingest_batch_id: 1,
      ingest_run_id: 1
    ]

    # NaiveDateTime.utc_now()

    CdmEtl.SetIngest.run!(args)
    |> Task.await(2_000_000)
  end
end
