defmodule CdmEtl.CdmApi.Item.Worker do
  use GenServer

  @moduledoc """
  Fetches and parses the compound info for a CONTENTdm Item
  """

  # allows us to refer to our struct w/out the full
  # module path
  alias __MODULE__

  defstruct([
    :base_url,
    http_client: Tesla
  ])

  # Client

  @timeout 100_000

  def run(id, callback) do
    Task.async(fn ->
      :poolboy.transaction(
        :item_worker,
        fn pid -> callback.(GenServer.call(pid, {:get, id}, @timeout)) end,
        @timeout
      )
    end)
  end

  @doc """
  Start the Process
  """
  def start_link(args \\ []) do
    IO.puts("Starting CDM Item Request Worker")
    GenServer.start_link(__MODULE__, struct(%Worker{}, args))
  end

  @impl true
  def init(worker) do
    {:ok, worker}
  end

  @impl true
  def handle_call({:get, id}, _from, worker) do
    IO.puts("Requesting CDM Item: #{id}")
    {:reply, fetch(worker, id), worker}
  end

  def get(pid, id) do
    GenServer.call(pid, {:get, id})
  end

  @doc """
  Convert a CONTENTdm Item Info response into a map

  ## Examples
      iex> item = ~s(
      ...> {
      ...> "title": "125th Anniversary Celebration, 1978",
      ...> "altern": {},
      ...> "creato": "Alexander, Jesse N.",
      ...> "contri": {},
      ...> "publis": {}
      ...> })
      ...> CdmEtl.CdmApi.Item.Worker.to_map(item)
      %{"altern" => %{}, "contri" => %{}, "creato" => "Alexander, Jesse N.", "publis" => %{}, "title" => "125th Anniversary Celebration, 1978"}
  """
  def to_map(item) do
    Jason.decode!(item)
    |> sanitize
  end

  defp sanitize(item)
       when item == %{
              "code" => "-2",
              "message" => "Requested item not found",
              "restrictionCode" => "-1"
            },
       do: %{}

  defp sanitize(item) when is_list(item), do: %{}
  defp sanitize(item), do: item

  defp fetch(%Worker{} = worker, id) do
    case CdmEtl.Request.fetch(
           [q: "dmGetItemInfo/#{id}/json"],
           worker.base_url,
           "/dmwebservices/index.php",
           worker.http_client
         ) do
      {:ok, response} -> response |> to_map |> Map.merge(%{"id" => id})
      {:timeout} -> {}
    end
  end
end
