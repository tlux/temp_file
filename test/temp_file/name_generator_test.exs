defmodule TempFile.NameGeneratorTest do
  use ExUnit.Case, async: true

  alias TempFile.NameGenerator

  describe "generate_name/0" do
    test "generate random name" do
      assert String.length(NameGenerator.generate_name(nil, [])) == 48
    end
  end

  describe "generate_name/1" do
    test "with string" do
      assert NameGenerator.generate_name("my-basename") =~
               ~r/\Amy-basename-(.{48})\z/
    end

    test "with options" do
      assert NameGenerator.generate_name(prefix: "my-prefix", extname: ".jpg") =~
               ~r/\Amy-prefix-(.{48}).jpg\z/
    end
  end

  describe "generate_name/2" do
    test "with no options" do
      assert String.length(NameGenerator.generate_name(nil, [])) == 48
    end

    test "with basename only" do
      assert NameGenerator.generate_name("my-basename", []) =~
               ~r/\Amy-basename-(.{48})\z/
    end

    test "with prefix only" do
      assert NameGenerator.generate_name(nil, prefix: "my-prefix") =~
               ~r/\Amy-prefix-(.{48})\z/
    end

    test "with suffix only" do
      assert NameGenerator.generate_name(nil, suffix: "txt") =~
               ~r/\A(.{48})-txt\z/
    end

    test "with extname only" do
      assert NameGenerator.generate_name(nil, extname: ".txt") =~
               ~r/\A(.{48}).txt\z/
    end

    test "with prefix and suffix" do
      assert NameGenerator.generate_name(nil,
               prefix: "my-prefix",
               suffix: "png"
             ) =~ ~r/\Amy-prefix-(.{48})-png\z/
    end

    test "with prefix and basename" do
      assert NameGenerator.generate_name("my-basename", prefix: "my-prefix") =~
               ~r/\Amy-prefix-my-basename-(.{48})\z/
    end

    test "with basename and suffix" do
      assert NameGenerator.generate_name("my-basename", suffix: "png") =~
               ~r/\Amy-basename-(.{48})-png\z/
    end

    test "with prefix, basename, suffix and extname" do
      assert NameGenerator.generate_name("my-basename",
               prefix: "my-prefix",
               suffix: "my-suffix",
               extname: ".jpg"
             ) =~ ~r/\Amy-prefix-my-basename-(.{48})-my-suffix.jpg\z/
    end
  end
end
