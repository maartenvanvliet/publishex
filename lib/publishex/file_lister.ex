defmodule Publishex.FileLister do
  @moduledoc """
  Module responsible for return list of paths for files to upload when supplied
  with a directory name.
  """
  @callback run(String.t()) :: list(binary())
end
