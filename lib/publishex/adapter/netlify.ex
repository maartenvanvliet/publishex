defmodule Publishex.Adapter.Netlify do
  @moduledoc "Adapter for uploading a directory to netlify"

  defmodule Deployment do
    @moduledoc false
    defstruct [:required, :id, :url]

    def build(id, required, url) do
      %__MODULE__{
        required: required,
        id: id,
        url: url
      }
    end
  end

  @doc """
  Publish to Netlify

      config = Publishex.Config.build([
        directory: "doc",
        adapter_opts: [token: "token", site_id: ""],
      ])
      Publishex.Adapter.Netlify.publish(config)

  """
  def publish(config) do
    token = config_key(config.adapter_opts, :token)
    site_id = config_key(config.adapter_opts, :site_id)
    client = Keyword.get(config.adapter_opts, :client, HTTPoison)

    directory = config.directory

    if !File.dir?(directory) do
      raise ArgumentError, "Not a valid directory"
    end

    files =
      directory
      |> config.file_lister.run()
      |> build_digests(directory, config.file_reader)

    case request_deploy(files, site_id, token, client) do
      {:ok, %{id: deploy_id, required: required_files, url: url}} ->
        files
        |> filter_required(required_files)
        |> config.upload_strategy.run(fn file ->
          IO.puts("Uploading #{file}...")
          path = directory <> file
          contents = config.file_reader.run(path)

          upload_file!(client, deploy_id, file, contents, token)
        end)

        IO.puts("Site uploaded: #{url}")

      {:error, error} ->
        raise error
    end
  end

  defp upload_file!(client, deploy_id, file, contents, token) do
    case client.put(
           build_deploy_file_url(deploy_id, file),
           contents,
           build_headers(token, "application/octet-stream")
         ) do
      {:ok, %{status_code: 200}} -> :ok
      {:ok, %{status_code: _, body: body}} -> raise parse_body(body)
      {:error, error} -> raise error
    end
  end

  defp request_deploy(files, site_id, token, client) do
    case client.post(build_deploy_url(site_id), build_deploy(files), build_headers(token)) do
      {:ok, %{body: body, status_code: 200}} ->
        %{"id" => deploy_id, "required" => required_files, "ssl_url" => url} = parse_body(body)
        deployment = Deployment.build(deploy_id, required_files, url)
        {:ok, deployment}

      {:ok, %{body: body, status_code: _}} ->
        {:error, parse_body(body)}

      {:error, error} ->
        {:error, error}
    end
  end

  defp build_headers(token, content \\ "application/json") do
    [{"Content-Type", content}, {"Authorization", "Bearer #{token}"}]
  end

  defp build_deploy(files) do
    Jason.encode!(%{
      "files" => files,
      "functions" => %{}
    })
  end

  defp filter_required(files, required_hashes) do
    Enum.filter(files, fn {_file, hash} ->
      Enum.member?(required_hashes, hash)
    end)
  end

  defp remove_prefix(path, prefix) do
    base = byte_size(prefix)
    <<_::binary-size(base), rest::binary>> = path
    rest
  end

  defp build_digests(paths, directory, file_reader) do
    paths
    |> Enum.map(fn path ->
      digest = remove_prefix(path, directory)
      {digest, hash_file(path, file_reader)}
    end)
    |> Map.new()
  end

  defp hash_file(path, file_reader) do
    Base.encode16(:crypto.hash(:sha, file_reader.run(path)), case: :lower)
  end

  defp base_url do
    "https://api.netlify.com/api/v1/"
  end

  defp build_deploy_file_url(deploy_id, file) do
    "#{base_url()}deploys/#{deploy_id}/files#{file}"
  end

  defp build_deploy_url(site_id) when is_binary(site_id) do
    "#{base_url()}sites/#{site_id}/deploys"
  end

  defp parse_body(body) do
    Jason.decode!(body)
  end

  defp config_key(opts, key) do
    case Keyword.fetch(opts, key) do
      {:ok, value} ->
        value

      :error ->
        raise ArgumentError,
              "Could not find required #{inspect(key)} in adapter_opts: #{inspect(opts)}"
    end
  end
end
