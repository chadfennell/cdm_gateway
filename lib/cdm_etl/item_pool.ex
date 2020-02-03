defmodule CdmEtl.CdmApi.Item.Pool do
  @moduledoc false

  use Application

  defp poolboy_config do
    [
      {:name, {:local, :item_worker}},
      {:worker_module, CdmEtl.CdmApi.Item.Worker},
      {:size, 20},
      {:max_overflow, 10}
    ]
  end

  def start(args \\ []) do
    children = [
      :poolboy.child_spec(:item_worker, poolboy_config(), args)
    ]

    opts = [strategy: :one_for_one, name: CdmEtl.CdmApi.Item.Worker]
    Supervisor.start_link(children, opts)
  end
end
