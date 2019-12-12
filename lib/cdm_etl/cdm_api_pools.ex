defmodule CdmApiPools do
  def start(cdm_base_url, oai_base_url) do
    [
      CdmEtl.CdmApi.Item.Pool.start(base_url: cdm_base_url),
      CdmEtl.CdmApi.Compounds.Pool.start(base_url: cdm_base_url),
      CdmEtl.CdmApi.IdentifierList.Pool.start(base_url: oai_base_url)
    ]
  end
end
