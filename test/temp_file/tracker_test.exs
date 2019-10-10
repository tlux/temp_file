defmodule TempFile.TrackerTest do
  use ExUnit.Case, async: true

  alias TempFile.Tracker

  describe "start_link/1" do
    test "start in default state" do
      start_supervised!(Tracker)

      assert :sys.get_state(Tracker) == %{
               enabled?: false,
               paths: MapSet.new()
             }
    end

    test "start in configured state" do
      Application.put_env(:temp_file, :tracker_enabled?, true)

      on_exit(fn ->
        Application.delete_env(:temp_file, :tracker_enabled?)
      end)

      start_supervised!(Tracker)

      assert :sys.get_state(Tracker) == %{
               enabled?: true,
               paths: MapSet.new()
             }
    end

    test "start in enabled state" do
      start_supervised!({Tracker, enabled: true})

      assert :sys.get_state(Tracker) == %{
               enabled?: true,
               paths: MapSet.new()
             }
    end

    test "start in disabled state" do
      start_supervised!({Tracker, enabled: false})

      assert :sys.get_state(Tracker) == %{
               enabled?: false,
               paths: MapSet.new()
             }
    end
  end

  describe "stop/0" do
    setup :create_test_dir

    test "cleanup files", %{test_dir: test_dir} do
      start_supervised!({Tracker, enabled: true})

      path_a = Path.join(test_dir, "lorem-ipsum.txt")
      path_b = Path.join(test_dir, "test-folder")

      :ok = Tracker.put_path(path_a)
      :ok = Tracker.put_path(path_b)

      assert :ok = Tracker.stop()

      refute File.exists?(path_a)
      refute File.exists?(path_b)
    end
  end

  describe "toggle_tracker/1" do
    test "enable tracker" do
      start_supervised!({Tracker, enabled: false})

      assert :ok = Tracker.toggle_tracker(true)
      assert :sys.get_state(Tracker).enabled? == true
    end

    test "disable tracker" do
      start_supervised!({Tracker, enabled: true})

      assert :ok = Tracker.toggle_tracker(false)
      assert :sys.get_state(Tracker).enabled? == false
    end
  end

  describe "put_path/1" do
    test "add path when tracking enabled" do
      start_supervised!({Tracker, enabled: true})

      assert :ok = Tracker.put_path("my/custom/path")
      assert :ok = Tracker.put_path("path/to/another/file.txt")
      assert :ok = Tracker.put_path("my/custom/path")

      assert :sys.get_state(Tracker).paths ==
               MapSet.new([
                 "my/custom/path",
                 "path/to/another/file.txt"
               ])
    end

    test "do not add path when tracking disabled" do
      start_supervised!({Tracker, enabled: false})

      assert :error = Tracker.put_path("my/custom/path")
      assert :error = Tracker.put_path("path/to/another/file.txt")
      assert :error = Tracker.put_path("my/custom/path")

      assert :sys.get_state(Tracker).paths == MapSet.new()
    end
  end

  describe "cleanup_files/0" do
    setup :create_test_dir

    test "remove tracked files", %{test_dir: test_dir} do
      start_supervised!({Tracker, enabled: true})

      path_a = Path.join(test_dir, "lorem-ipsum.txt")
      path_b = Path.join(test_dir, "test-folder")

      assert File.exists?(path_a)
      assert File.exists?(path_b)

      assert File.exists?(
               Path.join([test_dir, "test-folder", "lorem-ipsum.txt"])
             )

      :ok = Tracker.put_path(path_a)
      :ok = Tracker.put_path(path_b)

      assert :ok = Tracker.cleanup_files()

      refute File.exists?(path_a)
      refute File.exists?(path_b)
    end
  end

  defp create_test_dir(_) do
    dirname = Path.join(TempFile.dir(), to_string(System.system_time()))
    File.mkdir_p!(dirname)
    File.cp_r!("test/fixtures", dirname)
    on_exit(fn -> File.rm_rf!(dirname) end)
    {:ok, test_dir: dirname}
  end
end
