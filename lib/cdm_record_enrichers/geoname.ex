defmodule CdmRecordEnrichers.Geoname do
  alias __MODULE__

  defstruct([
    :username,
    :token,
    base_url: "http://ws.geonames.net",
    id: nil,
    http_client: Tesla
  ])

  def to_id(uri) when is_binary(uri) do
    Regex.replace(~r/\/$/, uri, "")
    |> String.split("/")
    |> Enum.take(-1)
    |> Enum.join()
  end

  def place(response) when is_map(response) do
    [
      response["name"],
      response["adminName1"],
      response["adminName2"]
    ]
    |> Enum.filter(fn place -> place != "Minnesota" end)
    |> Enum.uniq()
  end

  def place(_), do: nil

  def coordinates(%{lat: lat, lng: lng}) when is_binary(lat) and is_binary(lng) do
    "#{lat},#{lng}"
  end

  def coordinates(_), do: nil

  def fetch(%Geoname{} = geoname) do
    CdmEtl.Request.fetch(
      [
        username: geoname.username,
        token: geoname.token,
        geonameId: geoname.id
      ],
      geoname.base_url,
      "/getJSON",
      geoname.http_client
    )
    |> Jason.decode!()
  end
end
