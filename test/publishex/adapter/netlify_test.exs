defmodule Publishex.Adapter.NetlifyTest do
  use ExUnit.Case
  import ExUnit.CaptureIO

  defmodule FakeClient do
    def post(url, body, header) do
      send(self(), {url, body, header})

      {:ok,
       %HTTPoison.Response{
         status_code: 200,
         body: File.read!("test/fixtures/request_deploy.json")
       }}
    end

    def put(url, body, _headers) do
      send(self(), {:upload_file, url, body})
      {:ok, %{status_code: 200}}
    end
  end

  defmodule FakeLister do
    def run(_dir) do
      ["doc/123.html"]
    end
  end

  defmodule FakeReader do
    def run(file) do
      send(self(), {:read_file, file})
      "some content"
    end
  end

  test "returns error without token" do
    assert_raise ArgumentError, "Could not find required :token in adapter_opts: []", fn ->
      Publishex.publish("doc", adapter: Publishex.Adapter.Netlify)
    end
  end

  test "returns error without site id" do
    assert_raise ArgumentError,
                 "Could not find required :site_id in adapter_opts: [token: \"abc\"]",
                 fn ->
                   Publishex.publish("doc",
                     adapter: Publishex.Adapter.Netlify,
                     adapter_opts: [token: "abc"]
                   )
                 end
  end

  describe "upload" do
    test "returns d" do
      capture_io(fn ->
        Publishex.publish("doc",
          adapter: Publishex.Adapter.Netlify,
          file_lister: FakeLister,
          file_reader: FakeReader,
          upload_strategy: Publishex.UploadStrategy.Sync,
          adapter_opts: [
            token: "bogus_token",
            site_id: "awesome-austin-122b2d.netlify.com",
            client: FakeClient
          ]
        )
      end)

      assert_received {url, body, headers}

      assert "https://api.netlify.com/api/v1/sites/awesome-austin-122b2d.netlify.com/deploys" =
               url

      assert %{
               "files" => %{
                 "/123.html" => "94e66df8cd09d410c62d9e0dc59d3a884e458e05"
               },
               "functions" => %{}
             } = Jason.decode!(body)

      assert [
               {"Content-Type", "application/json"},
               {"Authorization", "Bearer bogus_token"}
             ] = headers

      assert_received {:read_file, "doc/123.html"}

      assert_received {:upload_file,
                       "https://api.netlify.com/api/v1/deploys/5d57d97123456782dcdbf7c5/files/123.html",
                       "some content"}
    end
  end
end
