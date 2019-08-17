defmodule Publishex.UploadStrategy do
  @moduledoc """
  Upload strategy of a list of files.

  Two options: `Publishex.UploadStrategy.Async` or `Publishex.UploadStrategy.Sync`
  Whether each file is uploaded asynchronously or synchronously. The latter
  is especially useful when testing.

  """
  @callback run(list(String.t()), fun(), list()) :: any
end
