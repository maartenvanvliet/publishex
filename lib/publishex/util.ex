defmodule Publishex.Util do
  def remove_prefix(path, prefix) do
    base = byte_size(prefix)
    <<_::binary-size(base), rest::binary>> = path
    rest
  end

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
