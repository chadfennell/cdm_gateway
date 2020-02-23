defmodule CdmRecordEnrichers.Field do
  def field(dest_record, label, value) do
    case sanitize(value) do
      %{} ->
        dest_record

      [] ->
        dest_record

      nil ->
        dest_record

      "" ->
        dest_record

      sanitized_value ->
        dest_record
        |> Map.merge(%{label => sanitized_value})
    end
  end

  defp sanitize(values) when is_list(values) do
    values
    |> Enum.map(&sanitize(&1))
  end

  defp sanitize(value) when is_binary(value) do
    String.trim(value)
  end

  defp sanitize(value), do: value
end
