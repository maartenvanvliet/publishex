defmodule Publishex.Adapter.S3Test do
  use ExUnit.Case
  import ExUnit.CaptureIO

  defmodule FakeClient do
    def request!(operation, opts) do
      send(self(), {:s3, operation, opts})

      :ok
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

  test "returns error without bucket" do
    assert_raise ArgumentError, "Could not find required :bucket in adapter_opts: []", fn ->
      Publishex.publish("doc", adapter: Publishex.Adapter.S3)
    end
  end

  test "returns error without access key id" do
    assert_raise ArgumentError,
                 "Could not find required :access_key_id in adapter_opts: [bucket: \"abc\"]",
                 fn ->
                   Publishex.publish("doc",
                     adapter: Publishex.Adapter.S3,
                     adapter_opts: [bucket: "abc"]
                   )
                 end
  end

  test "returns error without secret_access_key" do
    assert_raise ArgumentError,
                 "Could not find required :secret_access_key in adapter_opts: [bucket: \"abc\", access_key_id: \"access key\"]",
                 fn ->
                   Publishex.publish("doc",
                     adapter: Publishex.Adapter.S3,
                     adapter_opts: [bucket: "abc", access_key_id: "access key"]
                   )
                 end
  end

  test "returns error without region" do
    assert_raise ArgumentError,
                 "Could not find required :region in adapter_opts: [bucket: \"abc\", access_key_id: \"access key\", secret_access_key: \"secret\"]",
                 fn ->
                   Publishex.publish("doc",
                     adapter: Publishex.Adapter.S3,
                     adapter_opts: [
                       bucket: "abc",
                       access_key_id: "access key",
                       secret_access_key: "secret"
                     ]
                   )
                 end
  end

  test "returns error without acl" do
    assert_raise ArgumentError,
                 "Could not find required :acl in adapter_opts: [bucket: \"abc\", access_key_id: \"access key\", secret_access_key: \"secret\", region: \"us-west-1\"]",
                 fn ->
                   Publishex.publish("doc",
                     adapter: Publishex.Adapter.S3,
                     adapter_opts: [
                       bucket: "abc",
                       access_key_id: "access key",
                       secret_access_key: "secret",
                       region: "us-west-1"
                     ]
                   )
                 end
  end

  test "uploads files" do
    capture_io(fn ->
      Publishex.publish("doc",
        adapter: Publishex.Adapter.S3,
        file_lister: FakeLister,
        file_reader: FakeReader,
        upload_strategy: Publishex.UploadStrategy.Sync,
        adapter_opts: [
          bucket: "abc",
          access_key_id: "access key",
          secret_access_key: "secret",
          region: "region",
          acl: :public_read,
          client: FakeClient
        ]
      )
    end)

    assert_received {:s3, operation, opts}

    assert %{body: "some content", bucket: "abc", path: "/123.html"} = operation

    assert [
             region: "region",
             access_key_id: "access key",
             secret_access_key: "secret"
           ] = opts
  end
end
