defmodule TempFileTest do
  use ExUnit.Case, async: true

  describe "dir/0" do
    test "get default dir" do
      assert TempFile.dir() == "tmp"
    end

    test "get configured base dir" do
      dir = "tmp/custom"

      prev_dir = Application.get_env(:temp_file, :dir)
      Application.put_env(:temp_file, :dir, dir)
      on_exit(fn -> Application.put_env(:temp_file, :dir, prev_dir) end)

      assert TempFile.dir() == dir
    end
  end
end
