defmodule Publishex.UploadStrategy.Sync do
  @moduledoc false
  @behaviour Publishex.UploadStrategy

  @impl true
  def run(files, upload_file, _opts \\ []) do
    Enum.each(
      files,
      fn {file, _hash} ->
        upload_file.(file)
      end
    )
  end
end
