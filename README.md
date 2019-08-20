# Publishex
[![Hex pm](http://img.shields.io/hexpm/v/publishex.svg?style=flat)](https://hex.pm/packages/publishex) [![Hex Docs](https://img.shields.io/badge/hex-docs-9768d1.svg)](https://hexdocs.pm/publishex) [![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
-----

Publish a directory of static files to a static file hoster such as Netlify or S3. 

E.g. if you generate your `ex_doc` documentation for a private repository you can
publish this to a Netlify site. See for example [https://naughty-austin-122b2d.netlify.com/]

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `publishex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:publishex, "~> 1.0.1"}
  ]
end
```

## Usage

You can publish any directory but it defaults to `doc`. To publish your `ex_doc`
documentation to Netlify or S3 you can do the following.


### Netlify
```
# Generate the docs
mix docs

# Publish to netlify (defaults to `doc` directory)
mix publishex.netlify --token personal_access_token --site-id dazzling-tesla-122b2d.netlify.com

# Set custom directory
mix publishex.netlify --directory "some_dir" --token personal_access_token --site-id dazzling-tesla-122b2d.netlify.com

```

The personal access token can be created in the Netlify dashboard [https://app.netlify.com/user/applications#personal-access-tokens]

### S3
```
# Generate the docs
mix docs

# Publish to S3 (defaults to `doc` directory)
mix publishex.s3 --bucket bucket_name --region us-west-1 --access_key_id access_key_id --secret_access_key secret_access_key --acl public_read
```
Setting the ACL is explicit to prevent accidental public files.

See [https://docs.aws.amazon.com/AmazonS3/latest/dev/WebsiteHosting.html] on how to create a static site on S3


Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/publishex](https://hexdocs.pm/publishex).

