defmodule TempFile.NameGeneratorTest do
  use ExUnit.Case, async: true

  alias TempFile.NameGenerator

  describe "generate_filename/2" do
    test "with no options" do
      assert String.length(NameGenerator.generate_filename(nil, [])) == 48
    end

    test "with basename only" do
      assert NameGenerator.generate_filename("my-basename", []) =~
               ~r/\Amy-basename-(.*){48}\z/
    end

    test "with prefix only" do
      assert NameGenerator.generate_filename(nil, prefix: "my-prefix") =~
               ~r/\Amy-prefix-(.*){48}\z/
    end

    test "with suffix only" do
      assert NameGenerator.generate_filename(nil, suffix: ".txt") =~
               ~r/\A(.*){48}.txt\z/
    end

    test "with prefix and suffix" do
      assert NameGenerator.generate_filename(nil,
               prefix: "my-prefix",
               suffix: ".png"
             ) =~ ~r/\Amy-prefix-(.*){48}.png\z/
    end

    test "with prefix and basename" do
      assert NameGenerator.generate_filename("my-basename", prefix: "my-prefix") =~
               ~r/\Amy-prefix-my-basename-(.*){48}\z/
    end

    test "with basename and suffix" do
      assert NameGenerator.generate_filename("my-basename", suffix: ".png") =~
               ~r/\Amy-basename-(.*){48}.png\z/
    end

    test "with prefix, basename and suffix" do
      assert NameGenerator.generate_filename("my-basename",
               prefix: "my-prefix",
               suffix: ".jpg"
             ) =~ ~r/\Amy-prefix-my-basename-(.*){48}.jpg\z/
    end
  end
end
