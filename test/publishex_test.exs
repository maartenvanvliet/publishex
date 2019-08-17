defmodule PublishexTest do
  use ExUnit.Case

  defmodule FakeAdapter do
    def publish(config) do
      send(self(), config)
    end
  end

  test "publishes to adapter" do
    Publishex.publish("doc", adapter: FakeAdapter)

    assert_received(%Publishex.Config{
      adapter_opts: [],
      directory: "doc",
      file_lister: Publishex.FileLister.Default
    })
  end
end
