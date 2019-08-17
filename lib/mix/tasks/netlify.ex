defmodule Mix.Tasks.Publishex.Netlify do
  use Mix.Task

  @shortdoc "Publish a directory to Netlify"
  @moduledoc """
  Publish directory to Netlify

  ## Usage

      mix publishex.netlify --token personal_access_token --site-id dazzling-tesla-122b2d.netlify.com

      # Set a custom directory
      mix publishex.netlify --token personal_access_token --site-id dazzling-tesla-122b2d.netlify.com --directory "some_dir"

  """

  @impl Mix.Task
  def run(argv) do
    Application.ensure_all_started(:httpoison)

    parse_options = [strict: [token: :string, site_id: :string, directory: :string]]
    {opts, _args, _} = OptionParser.parse(argv, parse_options)

    directory = Keyword.get(opts, :directory, "doc")
    token = Keyword.fetch!(opts, :token)
    site_id = Keyword.fetch!(opts, :site_id)

    Publishex.publish(directory,
      adapter: Publishex.Adapter.Netlify,
      adapter_opts: [token: token, site_id: site_id]
    )
  end
end
