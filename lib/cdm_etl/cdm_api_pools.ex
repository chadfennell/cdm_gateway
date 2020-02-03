defmodule CdmApiPools do
  def start(base_url) do
    [
      CdmEtl.CdmApi.Item.Pool.start(base_url: base_url),
      CdmEtl.CdmApi.Compounds.Pool.start(base_url: base_url)
    ]
  end
end
