defmodule IdentifierstHttpClientPool do
  defmodule Response do
    def body do
      {:ok, xml} = File.read("test/fixtures/identifiers.xml")
      xml
    end
  end

  def get(_, _) do
    {:ok, Response}
  end

  def client(_), do: :client
end

defmodule CdmEtl.Oai.Identifier.WorkerTest do
  use ExUnit.Case

  @fake_item %{
    :identifiers => [
      %{
        datestamp: "2012-02-08",
        identifier: "oai:cdm16022.contentdm.oclc.org:swede/2",
        setSpec: "swede",
        status: "deleted"
      },
      %{
        datestamp: "2016-10-17",
        identifier: "oai:cdm16022.contentdm.oclc.org:swede/3",
        setSpec: "swede",
        status: ""
      }
    ],
    :deletables => [
      %{
        datestamp: "2012-02-08",
        identifier: "oai:cdm16022.contentdm.oclc.org:swede/2",
        setSpec: "swede",
        status: "deleted"
      }
    ],
    :updatables => ["swede/3"],
    :resumptionToken => "swede:200:swede:0000-00-00:9999-99-99:oai_dc"
  }

  setup do
    {:ok, pid} =
      CdmEtl.CdmApi.IdentifierList.Pool.start(
        base_url: "http://cdm16022.contentdm.oclc.org",
        http_client: IdentifierstHttpClientPool
      )

    %{server_pid: pid}
  end

  describe "when no resumptiom token is provided" do
    test "fetches a batch of identifiers with a resumption token", %{server_pid: pid} do
      callback = fn response ->
        send(self(), {:called_back, response})
      end

      task = CdmEtl.Oai.IdentifierList.Worker.run(callback, {:start, "swede"})
      ref = Process.monitor(task.pid)
      assert_receive {:DOWN, ^ref, :process, _, :normal}, 500
      assert Task.await(task, 50000) === {:called_back, @fake_item}
    end
  end

  describe "when a resumptiom token is provided" do
    test "fetches a batch of identifiers with a resumption token", %{server_pid: pid} do
      callback = fn response ->
        send(self(), {:called_back, response})
      end

      task = CdmEtl.Oai.IdentifierList.Worker.run(callback, {:next, "resumptionTokenHere:11122"})
      ref = Process.monitor(task.pid)
      assert_receive {:DOWN, ^ref, :process, _, :normal}, 500
      assert Task.await(task, 50000) === {:called_back, @fake_item}
    end
  end
end
