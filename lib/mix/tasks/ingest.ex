defmodule Mix.Tasks.CdmGateway.Ingest do
  use Mix.Task

  @shortdoc "Ingest from CONTENTdm"
  def run(_) do
    Mix.Task.run("app.start")

    CdmApiPools.start(
      "https://server16022.contentdm.oclc.org/",
      "http://cdm16022.contentdm.oclc.org",
      "p16022coll416"
    )

    args = [
      ingest_batch_id: 1,
      ingest_run_id: 1
    ]

    # {:ok, pid} = CdmEtl.SetIngest.start_link(args)
    # CdmEtl.SetIngest.run!(pid)
    # IO.inspect(pid)

    # children = [
    #   {DynamicSupervisor, strategy: :one_for_one, name: CdmEtl.IngestRun}
    # ]

    # Supervisor.start_link(children, strategy: :one_for_one)

    # result = DynamicSupervisor.start_child(CdmEtl.IngestRun, {CdmEtl.SetIngest, args})
    # IO.inspect("-----------#{inspect(result)}-----------------")

    # result = DynamicSupervisor.start_child(CdmEtl.IngestRun, {CdmEtl.SetIngest, args})
    # IO.inspect("-----------#{inspect(result)}++++++++++++++++++")
  end
end
