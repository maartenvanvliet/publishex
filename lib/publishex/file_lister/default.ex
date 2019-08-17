defmodule Publishex.FileLister.Default do
  @moduledoc false
  @behaviour Publishex.FileLister

  @impl true
  def run(directory) do
    glob = "#{directory}/**/*"

    glob
    |> Path.wildcard()
    |> filter_files
  end

  defp filter_files(paths) do
    Enum.filter(paths, fn path ->
      !File.dir?(path)
    end)
  end
end
