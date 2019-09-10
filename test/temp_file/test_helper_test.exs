defmodule TempFile.TestHelperTest do
  use ExUnit.Case, async: true

  import TempFile.TestHelper

  alias TempFile.Tracker

  setup :cleanup_temp_files_on_exit

  describe "cleanup_temp_files_on_exit/0" do
    test "start tracker and cleanup on exit" do
      path = TempFile.path(extname: ".dat")
      assert Tracker.get_paths() == [path]
      File.copy!("test/fixtures/lorem-ipsum.txt", path)
    end

    test "manual cleanup", context do
      assert :ok = cleanup_temp_files_on_exit(context)

      path = TempFile.path(extname: ".txt")
      assert Tracker.get_paths() == [path]
      File.copy!("test/fixtures/lorem-ipsum.txt", path)
    end

    test "private mode and subprocess" do
      set_temp_files_tracking_private()

      parent = self()

      path_a = TempFile.path(extname: ".txt")

      spawn_link(fn ->
        send(parent, {:path, TempFile.path(extname: ".txt")})
      end)

      assert_receive {:path, _path_b}
      assert Tracker.get_paths() == [path_a]
    end

    test "global mode and subprocess" do
      set_temp_files_tracking_global()

      parent = self()

      path_a = TempFile.path(extname: ".txt")

      spawn_link(fn ->
        send(parent, {:path, TempFile.path(extname: ".txt")})
      end)

      assert_receive {:path, path_b}
      assert Tracker.get_paths() == [path_a, path_b]
    end
  end
end
