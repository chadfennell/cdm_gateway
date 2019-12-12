defmodule CdmEtl.CdmApi.IdentifierList.Pool do
  @moduledoc false

  use Application

  defp poolboy_config do
    [
      {:name, {:local, :identifier_list_worker}},
      {:worker_module, CdmEtl.Oai.IdentifierList.Worker},
      {:size, 2},
      {:max_overflow, 2}
    ]
  end

  def start(args \\ []) do
    children = [
      :poolboy.child_spec(:identifier_list_worker, poolboy_config(), args)
    ]

    opts = [strategy: :one_for_one, name: CdmEtl.Oai.IdentifierList.Worker]
    Supervisor.start_link(children, opts)
  end
end
