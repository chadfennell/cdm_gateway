defmodule CompoundsHttpClient do
  defmodule Response do
    def body do
      {:ok, compounds} = File.read("test/fixtures/compounds.json")
      compounds
    end
  end

  def get(_, _) do
    {:ok, Response}
  end

  def client(_), do: :client
end

defmodule CdmEtl.CdmApi.Compounds.WorkerTest do
  use ExUnit.Case

  @fake_item ["swede/814", "swede/815", "swede/903"]

  setup do
    {:ok, pid} =
      CdmEtl.CdmApi.Compounds.Pool.start(
        base_url: "http://cdm16022.contentdm.oclc.org",
        http_client: CompoundsHttpClient
      )

    %{server_pid: pid}
  end

  test "fetches an Item JSON result" do
    callback = fn response ->
      send(self, {:called_back, response})
    end

    task = CdmEtl.CdmApi.Compounds.Worker.run("swede/999", callback)
    ref = Process.monitor(task.pid)
    assert_receive {:DOWN, ^ref, :process, _, :normal}, 500
    assert Task.await(task, 50000) === {:called_back, @fake_item}
  end
end
