defmodule CdmEtl.SetIngest do
  require Logger

  alias __MODULE__

  @timeout 5_000_000

  alias CdmEtl.Oai.IdentifierList

  defstruct([
    :caller,
    :set_spec,
    :identifier_list,
    compounds_worker: CdmEtl.CdmApi.Compounds.Worker,
    item_worker: CdmEtl.CdmApi.Item.Worker
  ])

  # Client

  def run(args) do
    extract_identifiers(struct(%SetIngest{}, args))
  end

  # Private

  defp extract_identifiers(set_ingest) do
    # Fetch data for each compound child if compound data exists
    set_ingest.identifier_list.updatables
    |> Enum.map(&compounds_worker(&1, set_ingest))
    |> Enum.map(&Task.await(&1, @timeout))

    # Process the Top Level / Primary Item Data
    # NOTE: THIS ASSUMES THAT CHILD RECORDS DO NOT SHOW IN OAI RESULTS
    # THESE MUST BE TURNED OFF IN CONTENTDM
    set_ingest.identifier_list.updatables
    |> Enum.map(&item_worker(&1, set_ingest, &1))
    |> Enum.map(&Task.await(&1, @timeout))

    # Process Deleted Records
    set_ingest.identifier_list.deletables
    |> Enum.map(&persist(&1, set_ingest, :deleted))

    # Allows clients to recursively iterrate through sets
    set_ingest.caller.callback(set_ingest)
  end

  defp compounds_worker(parent_id, set_ingest) do
    set_ingest.compounds_worker.run(parent_id, compounds_callback(parent_id, set_ingest))
  end

  defp item_worker(id, set_ingest, parent_id) do
    set_ingest.item_worker.run(id, item_callback(set_ingest, parent_id))
  end

  defp item_callback(set_ingest, parent_id) do
    fn item ->
      persist(item, parent_id, set_ingest, :active)
    end
  end

  def compounds_callback(parent_id, set_ingest) do
    fn items ->
      items
      |> Enum.map(&item_worker(&1, set_ingest, parent_id))
      |> Enum.map(&Task.await(&1, @timeout))
    end
  end

  defp persist(item, parent_id, set_ingest, :active) do
    try do
      %CdmGateway.Record{
        cdm_id: item["id"],
        metadata: item,
        set_spec: set_ingest.set_spec,
        parent_id: parent_id,
        is_deleted: false,
        is_primary: item["id"] == parent_id,
        cdm_modified: item["dmmodified"] |> to_naive_datetime
      }
      |> insert
    rescue
      e in RuntimeError -> log_error(e.message, item)
    end
  end

  defp persist(item, set_ingest, :deleted) do
    try do
      %CdmGateway.Record{
        cdm_id: item["id"],
        metadata: item,
        set_spec: set_ingest.set_spec,
        is_deleted: true,
        cdm_modified: item[:datestamp] |> to_naive_datetime
      }
      |> insert
    rescue
      e in RuntimeError -> log_error(e.message, item)
    end
  end

  defp insert(record) do
    CdmGateway.Repo.insert(record,
      on_conflict: :replace_all,
      conflict_target: :cdm_id
    )
  end

  defp log_error(error, item) do
    {:ok, file} = File.open("logs/error.log", [:append])
    IO.binwrite(file, "Error Inserting Item:#{inspect(item)} Error:#{error} \n")
    File.close(file)
  end

  defp to_naive_datetime(date) when is_binary(date) do
    [year, month, day] = date |> String.split("-") |> Enum.map(&String.to_integer(&1))

    %DateTime{
      year: year,
      month: month,
      day: day,
      hour: 0,
      minute: 0,
      second: 0,
      microsecond: {0, 0},
      utc_offset: 0,
      std_offset: 0,
      time_zone: "Central",
      zone_abbr: "CST"
    }
    |> DateTime.to_naive()
  end

  defp to_naive_datetime(_) do
    %DateTime{
      year: 1900,
      month: 01,
      day: 01,
      hour: 0,
      minute: 0,
      second: 0,
      microsecond: {0, 0},
      utc_offset: 0,
      std_offset: 0,
      time_zone: "Central",
      zone_abbr: "CST"
    }
    |> DateTime.to_naive()
  end
end
