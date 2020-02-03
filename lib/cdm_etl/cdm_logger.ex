defmodule CdmEtl.IngestLogger do
  def info(filename, message) do
    {:ok, file} = File.open("logs/#{filename}", [:append])
    IO.binwrite(file, "#{message}\n")
    File.close(file)
  end
end
