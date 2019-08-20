defmodule Publishex do
  @external_resource "./README.md"
  @moduledoc """
  #{File.read!(@external_resource) |> String.split("-----", parts: 2) |> List.last()}
  """

  defmodule Config do
    @moduledoc """
    Configuration module
    """
    defstruct [:file_lister, :adapter_opts, :directory, :upload_strategy, :file_reader]

    def build(opts) do
      %__MODULE__{
        directory: Keyword.fetch!(opts, :directory),
        adapter_opts: Keyword.get(opts, :adapter_opts, []),
        file_lister: Keyword.get(opts, :file_lister, Publishex.FileLister.Default),
        upload_strategy: Keyword.get(opts, :upload_strategy, Publishex.UploadStrategy.Async),
        file_reader: Keyword.get(opts, :file_reader, Publishex.FileReader)
      }
    end
  end

  @doc """
  Publish directory to static host.

  ## Netlify
      Publishex.publish("doc",
        adapter: Publishex.Adapter.Netlify,
        adapter_opts: [token: token, site_id: site_id]
      )

  ## S3
      Publishex.publish("doc",
        adapter: Publishex.Adapter.S3,
        adapter_opts: [bucket: "your.s3.bucket", region: "us-west-1", access_key_id: "access_key_id", secret_access_key: "secret_access_key"],
      ])

  """
  def publish(directory, opts) do
    config = Config.build(opts ++ [directory: directory])

    adapter = Keyword.fetch!(opts, :adapter)

    adapter.publish(config)
  end
end
