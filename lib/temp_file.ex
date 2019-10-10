defmodule TempFile do
  @moduledoc """
  The TempFile main module.
  """

  alias TempFile.NameGenerator
  alias TempFile.Tracker

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
  @spec path(basename_or_opts :: String.t() | Keyword.t()) :: Path.t()
  def path(basename_or_opts) do
    build_path(basename_or_opts)
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
  @spec path(basename :: String.t(), opts :: Keyword.t()) :: Path.t()
  def path(basename, opts) do
    build_path(basename, opts)
  end

  defp build_path(nil) do
    build_path(nil, [])
  end

  defp build_path(basename) when is_binary(basename) do
    build_path(basename, [])
  end

  defp build_path(opts) when is_list(opts) do
    build_path(nil, opts)
  end

  defp build_path(basename, opts) do
    path = Path.join(dir(), NameGenerator.generate_name(basename, opts))
    Tracker.put_path(path)
    path
  end

  @doc """
  Creates a temporary directory.

  You can pass a file basename or options described in `path/1` as the first
  argument.
  """
  @spec mkdir(basename_or_opts :: nil | String.t() | Keyword.t()) ::
          {:ok, Path.t()} | {:error, File.posix()}
  def mkdir(basename_or_opts \\ nil) do
    path = build_path(basename_or_opts)

    with :ok <- File.mkdir_p(path) do
      {:ok, path}
    end
  end

  @doc """
  Creates a temporary directory. Raises a `File.Error` in case of failure.

  You can pass a file basename or options described in `path/1` as the first
  argument.
  """
  @spec mkdir!(basename_or_opts :: nil | String.t() | Keyword.t()) :: Path.t()
  def mkdir!(basename_or_opts \\ nil) do
    path = build_path(basename_or_opts)
    File.mkdir_p!(path)
    path
  end

  @doc """
  Creates a temp file and writes the given contents to it.

  You can pass a file basename or options described in `path/1` as the first
  argument.
  """
  @spec write(
          basename_or_opts :: nil | String.t() | Keyword.t(),
          content :: binary
        ) :: {:ok, Path.t()} | {:error, File.posix()}
  def write(basename_or_opts \\ nil, content) do
    path = build_path(basename_or_opts)

    with :ok <- File.write(path, content) do
      {:ok, path}
    end
  end

  @doc """
  Creates a temp file and writes the given contents to it. Raises a `File.Error`
  in case of failure.

  You can pass a file basename or options described in `path/1` as the first
  argument.
  """
  @spec write!(
          basename_or_opts :: nil | String.t() | Keyword.t(),
          content :: binary
        ) :: Path.t()
  def write!(basename_or_opts \\ nil, content) do
    path = build_path(basename_or_opts)
    File.write!(path, content)
    path
  end

  @doc """
  Creates a temp file and opens it for writing.

  You can pass a file basename or options described in `path/1` as the first
  argument.
  """
  @spec open(basename_or_opts :: nil | String.t() | Keyword.t()) ::
          {:ok, Path.t(), File.io_device()} | {:error, File.posix()}
  def open(basename_or_opts) do
    open(basename_or_opts, [])
  end

  @doc """
  Creates a temp file and opens it for writing.

  You can pass a file basename or options described in `path/1` as the first
  argument.
  """
  @spec open(
          basename_or_opts :: nil | String.t() | Keyword.t(),
          modes_or_function :: [File.mode()] | (File.io_device() -> any)
        ) :: {:ok, Path.t(), File.io_device()} | {:error, File.posix()}
  def open(basename_or_opts, modes_or_function)

  def open(basename_or_opts, fun) when is_function(fun) do
    path = build_path(basename_or_opts)

    with {:ok, res} <- File.open(path, file_modes([]), fun) do
      {:ok, path, res}
    end
  end

  def open(basename_or_opts, modes) do
    path = build_path(basename_or_opts)

    with {:ok, res} <- File.open(path, file_modes(modes)) do
      {:ok, path, res}
    end
  end

  @doc """
  Creates a temp file and opens it for writing.

  You can pass a file basename or options described in `path/1` as the first
  argument.
  """
  @spec open(
          basename_or_opts :: nil | String.t() | Keyword.t(),
          modes :: [File.mode()],
          fun :: (File.io_device() -> res)
        ) :: {:ok, Path.t(), res} | {:error, File.posix()}
        when res: var
  def open(basename_or_opts, modes, fun) do
    path = build_path(basename_or_opts)

    with {:ok, res} <- File.open(path, file_modes(modes), fun) do
      {:ok, path, res}
    end
  end

  @doc """
  Creates a temp file and opens it for writing. Raises a `File.Error` in case of
  failure.

  You can pass a file basename or options described in `path/1` as the first
  argument.
  """
  @spec open!(basename_or_opts :: nil | String.t() | Keyword.t()) ::
          {Path.t(), File.io_device()}
  def open!(basename_or_opts) do
    open!(basename_or_opts, [])
  end

  @doc """
  Creates a temp file and opens it for writing. Raises a `File.Error` in case of
  failure.

  You can pass a file basename or options described in `path/1` as the first
  argument.
  """
  @spec open!(
          basename_or_opts :: nil | String.t() | Keyword.t(),
          modes_or_function :: [File.mode()] | (File.io_device() -> any)
        ) :: {Path.t(), File.io_device()}
  def open!(basename_or_opts, modes_or_function)

  def open!(basename_or_opts, fun) when is_function(fun) do
    path = build_path(basename_or_opts)
    res = File.open!(path, file_modes([]), fun)
    {path, res}
  end

  def open!(basename_or_opts, modes) do
    path = build_path(basename_or_opts)
    res = File.open!(path, file_modes(modes))
    {path, res}
  end

  @doc """
  Creates a temp file and opens it for writing. Raises a `File.Error` in case of
  failure.

  You can pass a file basename or options described in `path/1` as the first
  argument.
  """
  @spec open!(
          basename_or_opts :: nil | String.t() | Keyword.t(),
          modes :: [File.mode()],
          fun :: (File.io_device() -> res)
        ) :: {Path.t(), res}
        when res: var
  def open!(basename_or_opts, modes, fun) do
    path = build_path(basename_or_opts)
    res = File.open!(path, file_modes(modes), fun)
    {path, res}
  end

  defp file_modes(modes) when is_list(modes), do: [:write | modes]

  @doc """
  Gets the tracked paths.
  """
  @spec tracked_paths() :: [Path.t()]
  def tracked_paths do
    Tracker.get_paths()
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
