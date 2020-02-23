defmodule CdmRecordEnrichers.FieldFormatters do
  import String, only: [replace: 3, to_integer: 1, split: 2]
  import Enum, only: [join: 2, map: 2]
  import Logger, only: [error: 1]

  def remove_semicolon(string) when is_binary(string) do
    string
    |> replace(";", "")
  end

  def remove_semicolon(value), do: value

  def json_encode(records) when is_list(records) or is_map(records) do
    records
    |> Jason.encode!()
  end

  def json_encode(_), do: nil

  def to_i(value) when is_binary(value) do
    try do
      to_integer(value)
    rescue
      ArgumentError ->
        error("ArgumentError: cannot convert #{value} to integer")
        nil
    end
  end

  def to_i(value) when is_integer(value), do: value

  def to_i(_), do: nil

  def map_to_nil(value) when is_map(value), do: nil

  def map_to_nil(value), do: value

  def titleize(values) when is_list(values) do
    values
    |> map(&titleize(&1))
  end

  def titleize(value) when is_binary(value) do
    Recase.to_title(value)
  end

  def titleize(value) do
    error("Attempted but failed to titlize #{inspect(value)}")
    value
  end

  def join(values) when is_list(values) do
    values
    |> join(";")
  end

  def join(value), do: value

  def split(value) when is_binary(value) do
    value
    |> split(";")
  end

  def split(value), do: value

  def to_solr_id(cdm_id) do
    case cdm_id do
      id when is_binary(id) ->
        id
        |> split("/")
        |> join(":")

      _ ->
        nil
    end
  end
end
