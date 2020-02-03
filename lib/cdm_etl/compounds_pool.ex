defmodule CdmEtl.CdmApi.Compounds.Pool do
  @moduledoc false

  use Application

  defp poolboy_config do
    [
      {:name, {:local, :compounds_worker}},
      {:worker_module, CdmEtl.CdmApi.Compounds.Worker},
      {:size, 20},
      {:max_overflow, 10}
    ]
  end

  def start(args \\ []) do
    children = [
      :poolboy.child_spec(:compounds_worker, poolboy_config(), args)
    ]

    opts = [strategy: :one_for_one, name: CdmEtl.CdmApi.Compounds.Worker]
    Supervisor.start_link(children, opts)
  end
end
