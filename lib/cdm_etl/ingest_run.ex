# defmodule CdmEtl.IngestRun do
#   use DynamicSupervisor

#   require Logger

#   def start_link(cdm_base_url) do
#     CdmApiPools.start(cdm_base_url)
#     DynamicSupervisor.start_link(__MODULE__, nil, name: __MODULE__)
#   end

#   def init(args) do
#     DynamicSupervisor.init(strategy: :one_for_one)
#   end

#   # Logger.info(inspect(args))

#   # children = [
#   #   CdmEtl.SetIngest,
#   #   args
#   # ]

#   # Supervisor.init(children, strategy: :one_for_one, name: CdmEtl.IngestRun)
#   # config = args |> Map.delete(:cdm_base_url) |> to_keyword_list()

#   # def to_keyword_list(args) do
#   #   Enum.map(args, fn {key, value} -> {key, value} end)
#   # end
# end
