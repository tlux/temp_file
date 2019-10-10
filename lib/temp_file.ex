defmodule TempFile do
  @moduledoc """
  Documentation for TempFile.
  """

  alias TempFile.NameGenerator
  alias TempFile.Tracker

  @typedoc """
  A type representing a file tracker server.
  """
  @type tracker :: GenServer.server()

  @doc false
  @spec dir :: Path.t()
  def dir do
    Application.get_env(:temp_file, :dir) || System.tmp_dir!()
  end

  @doc """
  Gets the path to a temp file or directory.

  ## Example

      iex> TempFile.path()
      "tmp/sEUeC2zDsQuy_C9LJSTEQZVp1EPKlprLTPSTqStkplCraOWZ"
  """
  @spec path() :: Path.t()
  def path do
    build_path(nil, [])
  end

  @doc """
  Gets the path to a temp file or directory using a specified basename or
  options.

  ## Options

  * `:prefix` - A string to prepend to the randomly generated part in the
    filename.
  * `:suffix` - A string to append to the randomly generated part in the
    filename. Can be used to set a file extension.
  * `:extname` - An optional file extension to set for the temp file.

  ## Examples

      iex> TempFile.path("my-basename")
      "tmp/my-basename-sEUeC2zDsQuy_C9LJSTEQZVp1EPKlprLTPSTqStkplCraOWZ"

      iex> TempFile.path(prefix: "my-prefix")
      "tmp/my-prefix-sEUeC2zDsQuy_C9LJSTEQZVp1EPKlprLTPSTqStkplCraOWZ"

      iex> TempFile.path(extname: ".txt")
      "tmp/my-prefix-sEUeC2zDsQuy_C9LJSTEQZVp1EPKlprLTPSTqStkplCraOWZ.txt"

      iex> TempFile.path(prefix: "my-prefix", suffix: "txt")
      "tmp/my-prefix-sEUeC2zDsQuy_C9LJSTEQZVp1EPKlprLTPSTqStkplCraOWZ-txt"
  """
  @spec path(String.t() | Keyword.t()) :: Path.t()
  def path(basename_or_opts)

  def path(basename) when is_binary(basename) do
    build_path(basename, [])
  end

  def path(opts) when is_list(opts) do
    build_path(nil, opts)
  end

  @doc """
  Gets the path to a temp file or directory using a specified basename and
  options.

  ## Options

  * `:prefix` - A string to prepend to the randomly generated part in the
    filename.
  * `:suffix` - A string to append to the randomly generated part in the
    filename.
  * `:extname` - An optional file extension to set for the temp file.

  ## Examples

      iex> TempFile.path("my-basename", extname: ".png")
      "tmp/my-basename-sEUeC2zDsQuy_C9LJSTEQZVp1EPKlprLTPSTqStkplCraOWZ.png"

      iex> TempFile.path("my-basename", prefix: "my-prefix", extname: ".txt")
      "tmp/my-prefix-my-basename-sEUeC2zDsQuy_C9LJSTEQZVp1EPKlprLTPSTqStkplCraOWZ.txt"
  """
  @spec path(String.t(), Keyword.t()) :: Path.t()
  def path(basename, opts) do
    build_path(basename, opts)
  end

  defp build_path(basename, opts) do
    path = Path.join(dir(), NameGenerator.generate_name(basename, opts))
    Tracker.put_path(path)
    path
  end

  @doc """
  Enable temp file tracking. Tracked files are removed when calling `cleanup/0`
  or when the tracker process terminates.
  """
  @spec track() :: :ok
  def track do
    Tracker.toggle_tracker(true)
  end

  @doc """
  Disable temp file tracking.
  """
  @spec untrack() :: :ok
  def untrack do
    Tracker.toggle_tracker(false)
  end

  @doc """
  Remove all tracked files from the file system.
  """
  @spec cleanup() :: :ok
  def cleanup do
    Tracker.cleanup_files()
  end
end
