defmodule CdmEtl.SetIngest do
  require Logger

  alias __MODULE__

  @pool_timeout 2_000_000

  defstruct([
    :set_spec,
    :resumption_token,
    :callback,
    identifier_list_worker: CdmEtl.Oai.IdentifierList.Worker,
    compounds_worker: CdmEtl.CdmApi.Compounds.Worker,
    item_worker: CdmEtl.CdmApi.Item.Worker
  ])

  # Client

  def start(args) do
    set_ingest = struct(%SetIngest{}, args)

    set_ingest.identifier_list_worker.run(
      identifiers_callback(set_ingest),
      {:start, set_ingest.set_spec}
    )
  end

  def next(set_ingest) do
    set_ingest.identifier_list_worker.run(
      identifiers_callback(set_ingest),
      {:next, set_ingest.resumption_token}
    )
  end

  # Private

  defp identifiers_callback(set_ingest) do
    fn identifier_list ->
      extract_identifiers(identifier_list, set_ingest)
    end
  end

  defp extract_identifiers(identifier_list, set_ingest) do
    # Fetch data for each compound child if compound data exists
    identifier_list.updatables
    |> Enum.map(&compounds_worker(&1, set_ingest))

    # Process the Top Level / Primary Item Data
    identifier_list.updatables
    |> Enum.map(&item_worker(&1, set_ingest, &1))
    |> Enum.map(&Task.await(&1))

    # Process Deleted Records
    identifier_list.deletables
    |> Enum.map(&persist(&1, nil, set_ingest, :deleted))

    # Allows clients to iterrate through sets
    set_ingest.callback.(identifier_list, set_ingest)
  end

  defp compounds_worker(parent_id, set_ingest) do
    set_ingest.compounds_worker.run(parent_id, compounds_callback(parent_id, set_ingest))
    |> Task.await(@pool_timeout)
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
      |> Enum.map(&Task.await(&1))
    end
  end

  defp persist(item, parent_id, set_ingest, :active) do
    id = item["id"]
    modified = item["dmmodified"]
    Logger.info("ACTIVE: Persist: #{id} #{parent_id} #{inspect(set_ingest)} #{modified}")
  end

  defp persist(item, _, set_ingest, :deleted) do
    id = item["id"]
    modified = item["datestamp"]
    Logger.info("DELETED: Persist: #{id}  #{inspect(set_ingest)} #{modified}")
  end
end
