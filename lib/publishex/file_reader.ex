defmodule Publishex.FileReader do
  @moduledoc """
  Proxy for reading files.
  """
  @callback run(String.t()) :: String.t()

  def run(file) do
    File.read!(file)
  end
end
