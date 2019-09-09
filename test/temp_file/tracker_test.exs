defmodule TempFile.TrackerTest do
  use ExUnit.Case, async: true

  alias TempFile.NameGenerator
  alias TempFile.Tracker

  describe "stop/0" do
    test "cleanup files" do
      dirname = setup_test_dir()
      {:ok, _} = Tracker.start_link()

      path_a = Path.join(dirname, "lorem-ipsum.txt")
      path_b = Path.join(dirname, "test-folder")

      :ok = Tracker.put_path(path_a)
      :ok = Tracker.put_path(path_b)

      assert :ok = Tracker.stop()

      refute File.exists?(path_a)
      refute File.exists?(path_b)
    end
  end

  defp setup_test_dir do
    dirname = Path.join("tmp", NameGenerator.generate_name())
    File.mkdir_p!(dirname)
    File.cp_r!("test/fixtures", dirname)
    on_exit(fn -> File.rm_rf!(dirname) end)
    dirname
  end

  describe "get_paths/0" do
    setup do
      start_supervised!(Tracker)
      :ok
    end

    test "empty list when no paths tracked" do
      assert Tracker.get_paths() == []
    end

    test "list tracked paths" do
      assert :ok = Tracker.put_path("my/custom/path")
      assert :ok = Tracker.put_path("path/to/another/file.txt")
      assert :ok = Tracker.put_path("my/custom/path")

      assert Tracker.get_paths() == [
               "my/custom/path",
               "path/to/another/file.txt"
             ]
    end
  end

  describe "put_path/1" do
    test "ok when server not running" do
      assert :ok = Tracker.put_path("my/custom/path")
    end

    test "ok when server running" do
      start_supervised!(Tracker)

      assert :ok = Tracker.put_path("my/custom/path")
      assert :ok = Tracker.put_path("path/to/another/file.txt")
      assert :ok = Tracker.put_path("my/custom/path")

      assert Tracker.get_paths() == [
               "my/custom/path",
               "path/to/another/file.txt"
             ]
    end
  end

  describe "cleanup_files/0" do
    setup do
      start_supervised!(Tracker)
      dirname = setup_test_dir()
      {:ok, dirname: dirname}
    end

    test "do not remove untracked files" do
      assert Tracker.cleanup_files() == []
    end

    test "remove tracked files", %{dirname: dirname} do
      path_a = Path.join(dirname, "lorem-ipsum.txt")
      path_b = Path.join(dirname, "test-folder")

      assert File.exists?(path_a)
      assert File.exists?(path_b)

      assert File.exists?(
               Path.join([dirname, "test-folder", "lorem-ipsum.txt"])
             )

      :ok = Tracker.put_path(path_a)
      :ok = Tracker.put_path(path_b)

      assert Tracker.cleanup_files() == [path_a, path_b]

      refute File.exists?(path_a)
      refute File.exists?(path_b)
    end
  end
end