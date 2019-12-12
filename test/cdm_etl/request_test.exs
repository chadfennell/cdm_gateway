defmodule OkReuestHttpClient do
  defmodule Response do
    def body do
      "some data here"
    end
  end

  def get(_, _) do
    {:ok, Response}
  end

  def client(_), do: :client
end

defmodule TimeoutReuestHttpClient do
  defmodule Response do
    def body do
      "some data here"
    end
  end

  def get(_, _) do
    {:error, :timeout}
  end

  def client(_), do: :client
end

defmodule ConnectionRefusedReuestHttpClient do
  defmodule Response do
    def body do
      "some data here"
    end
  end

  def get(_, _) do
    {:error, :econnrefused}
  end

  def client(_), do: :client
end

defmodule CdmEtl.CdmApi.RequestTest do
  use ExUnit.Case
  doctest CdmEtl.Request

  describe "when an endpoint times out" do
    test "returns a timeout message" do
      assert CdmEtl.Request.fetch(nil, nil, nil, TimeoutReuestHttpClient) ==
               {:error, :timeout}
    end
  end

  describe "when an endpoint refused to connect" do
    test "raises an exception" do
      assert_raise RuntimeError, "Connection Refused for ", fn ->
        CdmEtl.Request.fetch(nil, nil, nil, ConnectionRefusedReuestHttpClient)
      end
    end
  end
end
