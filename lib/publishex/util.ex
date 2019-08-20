defmodule Publishex.Util do
  @moduledoc """
  Utility functions used by adapters
  """

  @doc """
  Remove prefix from a string
  """
  def remove_prefix(path, prefix) do
    base = byte_size(prefix)
    <<_::binary-size(base), rest::binary>> = path
    rest
  end

  @doc """
  Check keyword list for presence of key and raise with error otherwise
  """
  def config_key(opts, key) do
    case Keyword.fetch(opts, key) do
      {:ok, value} ->
        value

      :error ->
        raise ArgumentError,
              "Could not find required #{inspect(key)} in adapter_opts: #{inspect(opts)}"
    end
  end
end
