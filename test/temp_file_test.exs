defmodule TempFileTest do
  use ExUnit.Case, async: true

  describe "__base_dir__/0" do
    test "get default base dir" do
      assert TempFile.__base_dir__() == "tmp"
    end

    test "get configured base dir" do
      base_dir = "tmp/custom"

      Application.put_env(:temp_file, :base_dir, base_dir)
      on_exit(fn -> Application.delete_env(:temp_file, :base_dir) end)

      assert TempFile.__base_dir__() == base_dir
    end
  end
end
