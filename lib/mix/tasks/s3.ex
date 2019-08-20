defmodule Mix.Tasks.Publishex.S3 do
  use Mix.Task

  @shortdoc "Publish a directory to S3"
  @moduledoc """
  Publish directory to S3

  ## Usage

      mix publishex.s3 --bucket bucket_name --region us-west-1 --access_key_id access_key_id --secret_access_key secret_access_key --acl public_read

      # Set a custom directory
      mix publishex.s3 --bucket bucket_name --region us-west-1 --access_key_id access_key_id --secret_access_key secret_access_key --acl public_read --directory "some_dir"

  You have to explicitly pass the acl so files are not accidentally made public
  The values can be any of the following `private`, `public_read`, `public_read_write`, `authenticated_read`, `bucket_owner_read` or `bucket_owner_full_control`.

  """

  @impl Mix.Task
  def run(argv) do
    Application.ensure_all_started(:httpoison)

    parse_options = [
      strict: [
        bucket: :string,
        region: :string,
        directory: :string,
        secret_access_key: :string,
        access_key_id: :string,
        acl: :string
      ]
    ]

    {opts, _args, _} = OptionParser.parse(argv, parse_options)

    directory = Keyword.get(opts, :directory, "doc")
    bucket = Keyword.fetch!(opts, :bucket)
    region = Keyword.fetch!(opts, :region)
    access_key_id = Keyword.fetch!(opts, :access_key_id)
    secret_access_key = Keyword.fetch!(opts, :secret_access_key)
    acl = Keyword.fetch!(opts, :acl)

    Publishex.publish(directory,
      adapter: Publishex.Adapter.S3,
      adapter_opts: [
        bucket: bucket,
        region: region,
        access_key_id: access_key_id,
        secret_access_key: secret_access_key,
        acl: String.to_atom(acl)
      ]
    )
  end
end
