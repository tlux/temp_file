defmodule TempFileTest do
  use ExUnit.Case

  alias TempFile.Tracker

  @content "Lorem Ipsum"

  describe "dir/0" do
    test "get configured dir" do
      assert TempFile.dir() == "tmp/test"
    end

    test "get system temp when not configured" do
      prev_dir = Application.get_env(:temp_file, :dir)
      Application.delete_env(:temp_file, :dir)
      on_exit(fn -> Application.put_env(:temp_file, :dir, prev_dir) end)

      assert TempFile.dir() == System.tmp_dir!()
    end
  end

  describe "path/0" do
    test "build path" do
      start_supervised!({Tracker, enabled: true})

      path = TempFile.path()

      assert path =~ ~r/\Atmp\/test\/([A-Za-z0-9-_]){48}\z/
      assert TempFile.tracked_paths() == [path]
    end
  end

  describe "path/1" do
    setup do
      start_supervised!({Tracker, enabled: true})
      :ok
    end

    test "build path with nil arg" do
      path = TempFile.path(nil)

      assert path =~ ~r/\Atmp\/test\/([A-Za-z0-9-_]){48}\z/
      assert TempFile.tracked_paths() == [path]
    end

    test "build path with empty keyword list arg" do
      path = TempFile.path([])

      assert path =~ ~r/\Atmp\/test\/([A-Za-z0-9-_]){48}\z/
      assert TempFile.tracked_paths() == [path]
    end

    test "build path with basename" do
      path = TempFile.path("my-basename")

      assert path =~ ~r/\Atmp\/test\/my-basename-([A-Za-z0-9-_]){48}\z/
      assert TempFile.tracked_paths() == [path]
    end

    test "build path with opts" do
      path =
        TempFile.path(prefix: "my-prefix", suffix: "my-suffix", extname: ".txt")

      assert path =~
               ~r/\Atmp\/test\/my-prefix-([A-Za-z0-9-_]){48}-my-suffix.txt\z/

      assert TempFile.tracked_paths() == [path]
    end
  end

  describe "path/2" do
    test "build path with basename and opts" do
      start_supervised!({Tracker, enabled: true})

      path =
        TempFile.path(
          "my-basename",
          prefix: "my-prefix",
          suffix: "my-suffix",
          extname: ".txt"
        )

      assert path =~
               ~r/\Atmp\/test\/my-prefix-my-basename-([A-Za-z0-9-_]){48}-my-suffix.txt\z/

      assert TempFile.tracked_paths() == [path]
    end
  end

  describe "mkdir/0" do
    test "create dir" do
      start_supervised!({Tracker, enabled: true})

      assert {:ok, path} = TempFile.mkdir()
      assert path =~ ~r/\Atmp\/test\/([A-Za-z0-9-_]){48}\z/
      assert File.dir?(path)
      assert TempFile.tracked_paths() == [path]
    end
  end

  describe "mkdir/1" do
    setup do
      start_supervised!({Tracker, enabled: true})
      :ok
    end

    test "create dir with basename" do
      assert {:ok, path} = TempFile.mkdir("my-basename")
      assert path =~ ~r/\Atmp\/test\/my-basename-([A-Za-z0-9-_]){48}\z/
      assert File.dir?(path)
      assert TempFile.tracked_paths() == [path]
    end

    test "create dir with opts" do
      assert {:ok, path} =
               TempFile.mkdir(prefix: "my-prefix", suffix: "my-suffix")

      assert path =~ ~r/\Atmp\/test\/my-prefix-([A-Za-z0-9-_]){48}-my-suffix\z/
      assert File.dir?(path)
      assert TempFile.tracked_paths() == [path]
    end
  end

  describe "mkdir!/0" do
    test "create dir" do
      start_supervised!({Tracker, enabled: true})

      path = TempFile.mkdir!()

      assert File.dir?(path)
      assert TempFile.tracked_paths() == [path]
    end
  end

  describe "mkdir!/1" do
    setup do
      start_supervised!({Tracker, enabled: true})
      :ok
    end

    test "create dir with basename" do
      path = TempFile.mkdir!("my-basename")

      assert path =~ ~r/\Atmp\/test\/my-basename-([A-Za-z0-9-_]){48}\z/
      assert File.dir?(path)
      assert TempFile.tracked_paths() == [path]
    end

    test "create dir with opts" do
      path = TempFile.mkdir!(prefix: "my-prefix", suffix: "my-suffix")

      assert path =~ ~r/\Atmp\/test\/my-prefix-([A-Za-z0-9-_]){48}-my-suffix\z/
      assert File.dir?(path)
      assert TempFile.tracked_paths() == [path]
    end
  end

  describe "write/1" do
    test "write contents to temp file" do
      start_supervised!({Tracker, enabled: true})

      assert {:ok, path} = TempFile.write(@content)
      assert path =~ ~r/\Atmp\/test\/([A-Za-z0-9-_]){48}\z/
      assert File.regular?(path)
      assert File.read!(path) == @content
      assert TempFile.tracked_paths() == [path]
    end
  end

  describe "write/2" do
    setup do
      start_supervised!({Tracker, enabled: true})
      :ok
    end

    test "write contents to temp file with basename" do
      assert {:ok, path} = TempFile.write("my-basename", @content)
      assert path =~ ~r/\Atmp\/test\/my-basename-([A-Za-z0-9-_]){48}\z/
      assert File.regular?(path)
      assert File.read!(path) == @content
      assert TempFile.tracked_paths() == [path]
    end

    test "write contents to temp file with name opts" do
      assert {:ok, path} =
               TempFile.write(
                 [prefix: "my-prefix", suffix: "my-suffix"],
                 @content
               )

      assert path =~ ~r/\Atmp\/test\/my-prefix-([A-Za-z0-9-_]){48}-my-suffix\z/
      assert File.regular?(path)
      assert File.read!(path) == @content
      assert TempFile.tracked_paths() == [path]
    end
  end

  describe "write!/1" do
    test "write contents to temp file" do
      start_supervised!({Tracker, enabled: true})

      path = TempFile.write!(@content)

      assert path =~ ~r/\Atmp\/test\/([A-Za-z0-9-_]){48}\z/
      assert File.regular?(path)
      assert File.read!(path) == @content
      assert TempFile.tracked_paths() == [path]
    end
  end

  describe "write!/2" do
    setup do
      start_supervised!({Tracker, enabled: true})
      :ok
    end

    test "write contents to temp file with basename" do
      path = TempFile.write!("my-basename", @content)

      assert path =~ ~r/\Atmp\/test\/my-basename-([A-Za-z0-9-_]){48}\z/
      assert File.regular?(path)
      assert File.read!(path) == @content
      assert TempFile.tracked_paths() == [path]
    end

    test "write contents to temp file with name opts" do
      path =
        TempFile.write!(
          [prefix: "my-prefix", suffix: "my-suffix"],
          @content
        )

      assert path =~ ~r/\Atmp\/test\/my-prefix-([A-Za-z0-9-_]){48}-my-suffix\z/
      assert File.regular?(path)
      assert File.read!(path) == @content
      assert TempFile.tracked_paths() == [path]
    end
  end

  describe "open/1" do
    setup do
      start_supervised!({Tracker, enabled: true})
      :ok
    end

    test "open file with basename" do
      assert {:ok, path, file} = TempFile.open("my-basename")
      on_exit(fn -> File.close(file) end)

      assert path =~ ~r/\Atmp\/test\/my-basename-([A-Za-z0-9-_]){48}\z/
      assert IO.binwrite(file, @content)

      File.close(file)

      assert File.read!(path) == @content
    end

    test "open file with name opts" do
      assert {:ok, path, file} =
               TempFile.open(prefix: "my-prefix", suffix: "my-suffix")

      on_exit(fn -> File.close(file) end)

      assert path =~ ~r/\Atmp\/test\/my-prefix-([A-Za-z0-9-_]){48}-my-suffix\z/
      assert IO.binwrite(file, @content)

      File.close(file)

      assert File.read!(path) == @content
    end
  end

  describe "open/2" do
    setup do
      start_supervised!(Tracker)
      :ok
    end

    test "open file with basename and modes" do
      assert {:ok, path, file} = TempFile.open("my-basename", [:binary])
      on_exit(fn -> File.close(file) end)

      assert path =~ ~r/\Atmp\/test\/my-basename-([A-Za-z0-9-_]){48}\z/
      assert IO.binwrite(file, @content)

      File.close(file)

      assert File.read!(path) == @content
    end

    test "open file with basename and function" do
      assert {:ok, path, :hello} =
               TempFile.open("my-basename", fn file ->
                 IO.binwrite(file, @content)
                 :hello
               end)

      assert path =~ ~r/\Atmp\/test\/my-basename-([A-Za-z0-9-_]){48}\z/
      assert File.read!(path) == @content
    end
  end

  describe "open/3" do
    test "open file with name opts and function" do
      start_supervised!(Tracker)

      assert {:ok, path, res} =
               TempFile.open([prefix: "my-prefix"], [:binary], fn file ->
                 IO.binwrite(file, @content)
                 :hello
               end)

      assert path =~ ~r/\Atmp\/test\/my-prefix-([A-Za-z0-9-_]){48}\z/
      assert File.read!(path) == @content
      assert res == :hello
    end
  end

  describe "open!/1" do
    setup do
      start_supervised!({Tracker, enabled: true})
      :ok
    end

    test "open file with basename" do
      {path, file} = TempFile.open!("my-basename")
      on_exit(fn -> File.close(file) end)

      assert path =~ ~r/\Atmp\/test\/my-basename-([A-Za-z0-9-_]){48}\z/
      assert IO.binwrite(file, @content)

      File.close(file)

      assert File.read!(path) == @content
    end

    test "open file with name opts" do
      {path, file} = TempFile.open!(prefix: "my-prefix", suffix: "my-suffix")
      on_exit(fn -> File.close(file) end)

      assert path =~ ~r/\Atmp\/test\/my-prefix-([A-Za-z0-9-_]){48}-my-suffix\z/
      assert IO.binwrite(file, @content)

      File.close(file)

      assert File.read!(path) == @content
    end
  end

  describe "open!/2" do
    setup do
      start_supervised!(Tracker)
      :ok
    end

    test "open file with basename and modes" do
      assert {path, file} = TempFile.open!("my-basename", [:binary])
      on_exit(fn -> File.close(file) end)

      assert path =~ ~r/\Atmp\/test\/my-basename-([A-Za-z0-9-_]){48}\z/
      assert IO.binwrite(file, @content)

      File.close(file)

      assert File.read!(path) == @content
    end

    test "open file with basename and function" do
      assert {path, :hello} =
               TempFile.open!("my-basename", fn file ->
                 IO.binwrite(file, @content)
                 :hello
               end)

      assert path =~ ~r/\Atmp\/test\/my-basename-([A-Za-z0-9-_]){48}\z/
      assert File.read!(path) == @content
    end
  end

  describe "open!/3" do
    test "open file with name opts and function" do
      start_supervised!(Tracker)

      assert {path, res} =
               TempFile.open!([prefix: "my-prefix"], [:binary], fn file ->
                 IO.binwrite(file, @content)
                 :hello
               end)

      assert path =~ ~r/\Atmp\/test\/my-prefix-([A-Za-z0-9-_]){48}\z/
      assert File.read!(path) == @content
      assert res == :hello
    end
  end

  describe "track/0" do
    test "enable tracking" do
      start_supervised!({Tracker, enabled: false})

      assert :ok = TempFile.track()
      assert Tracker.tracker_enabled?() == true
    end
  end

  describe "untrack/0" do
    test "disable tracking" do
      start_supervised!({Tracker, enabled: true})

      assert :ok = TempFile.untrack()
      assert Tracker.tracker_enabled?() == false
    end
  end

  describe "cleanup/0" do
    test "remove tracked files" do
      start_supervised!({Tracker, enabled: true})

      source_path = "test/fixtures/lorem-ipsum.txt"
      path_a = TempFile.path()
      path_b = TempFile.path()

      File.cp(source_path, path_a)
      File.cp(source_path, path_b)

      assert path_a in TempFile.tracked_paths()
      assert path_b in TempFile.tracked_paths()
      assert :ok = TempFile.cleanup()
      assert path_a not in TempFile.tracked_paths()
      assert path_b not in TempFile.tracked_paths()
    end
  end
end
