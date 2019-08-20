defmodule Publishex.Adapter.S3 do
  @moduledoc "Adapter for uploading a directory to netlify"

  alias ExAws.S3
  alias Publishex.Util

  @doc """
  Publish to S3

      config = Publishex.Config.build([
        directory: "doc",
        adapter_opts: [bucket: "your.s3.bucket", region: "us-west-1", access_key_id: "access_key_id", secret_access_key: "secret_access_key"],
      ])
      Publishex.Adapter.S3.publish(config)

  """
  def publish(config) do
    bucket = Util.config_key(config.adapter_opts, :bucket)
    access_key_id = Util.config_key(config.adapter_opts, :access_key_id)
    secret_access_key = Util.config_key(config.adapter_opts, :secret_access_key)
    region = Util.config_key(config.adapter_opts, :region)
    acl = Util.config_key(config.adapter_opts, :acl)
    client = Keyword.get(config.adapter_opts, :client, ExAws)

    directory = config.directory

    if !File.dir?(directory) do
      raise ArgumentError, "Not a valid directory"
    end

    directory
    |> config.file_lister.run()
    |> build_src_dests(directory)
    |> config.upload_strategy.run(fn {src, dest} ->
      IO.puts("Uploading #{src} to #{dest}...")

      "." <> ext = Path.extname(src)

      S3.put_object(bucket, dest, config.file_reader.run(src),
        content_type: "text/#{ext}",
        acl: acl
      )
      |> client.request!(
        region: region,
        access_key_id: access_key_id,
        secret_access_key: secret_access_key
      )
    end)

    IO.puts("Site uploaded to bucket: #{bucket}")
  end

  defp build_src_dests(paths, prefix) do
    paths
    |> Enum.map(fn path ->
      {path, Util.remove_prefix(path, prefix)}
    end)
    |> Map.new()
  end
end
