defmodule CdmEtl.Oai.IdentifierList.Test do
  use ExUnit.Case, async: true

  alias CdmEtl.Oai.IdentifierList

  describe "when no resumptiom token is provided" do
    test "fetches the first batch of identifiers" do
      args = [
        base_url: "http://cdm16022.contentdm.oclc.org",
        set_spec: "swede"
      ]

      identifier_list = IdentifierList.get(args)
      assert identifier_list.resumptionToken == "swede:200:swede:0000-00-00:9999-99-99:oai_dc"
    end
  end

  describe "when a resumptiom token is provided" do
    test "fetches the second batch of identifiers" do
      args = [
        base_url: "http://cdm16022.contentdm.oclc.org",
        resumption_token: "swede:200:swede:0000-00-00:9999-99-99:oai_dc"
      ]

      identifier_list = IdentifierList.get(args)
      assert identifier_list.resumptionToken == "swede:400:swede:0000-00-00:9999-99-99:oai_dc"
    end
  end
end
