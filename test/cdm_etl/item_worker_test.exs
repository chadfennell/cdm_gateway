defmodule ItemFirstHttpClient do
  defmodule Response do
    def body do
      {:ok, xml} = File.read("test/fixtures/item.json")
      xml
    end
  end

  def get(_, _) do
    {:ok, Response}
  end

  def client(_), do: :client
end

defmodule CdmEtl.CdmApi.Item.WorkerTest do
  use ExUnit.Case
  doctest CdmEtl.CdmApi.Item.Worker

  @fake_item %{
    "id" => "swede/999",
    "altern" => %{},
    "captio" => %{},
    "cdmisnewspaper" => "0",
    "contri" => %{},
    "creato" => "Alexander, Jesse N.",
    "publis" => %{},
    "title" => "125th Anniversary Celebration, 1978. (Box 1, Folder 20)"
  }

  setup do
    {:ok, pid} =
      CdmEtl.CdmApi.Item.Pool.start(
        base_url: "http://cdm16022.contentdm.oclc.org",
        http_client: ItemFirstHttpClient
      )

    %{server_pid: pid}
  end

  test "fetches an Item JSON result" do
    callback = fn response ->
      send(self(), {:called_back, response})
    end

    task = CdmEtl.CdmApi.Item.Worker.run("swede/999", callback)
    ref  = Process.monitor(task.pid)
    assert_receive {:DOWN, ^ref, :process, _, :normal}, 500
    assert Task.await(task, 50000) === {:called_back, @fake_item}
  end
end
