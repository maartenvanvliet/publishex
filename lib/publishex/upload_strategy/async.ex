defmodule Publishex.UploadStrategy.Async do
  @moduledoc false
  @behaviour Publishex.UploadStrategy

  @impl true
  def run(files, upload_file, opts \\ [max_concurrency: 10]) do
    Task.async_stream(
      files,
      fn file ->
        upload_file.(file)
      end,
      opts
    )
    |> Stream.run()
  end
end
