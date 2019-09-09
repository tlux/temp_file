defmodule TempFile.Tracker do
  @moduledoc """
  A server that tracks all temp paths generated during its runtime. Can be used
  to cleanup all tracked files when needed. Automatically clears all tracked
  files when the server terminates.

  ## Usage in Tests

  TODO
  """

  use GenServer

  @initial_value MapSet.new()

  @doc """
  Starts the tracker.
  """
  @spec start_link(Keyword.t()) :: Agent.on_start()
  def start_link(opts \\ []) do
    opts = Keyword.put(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @doc """
  Stops the tracker.
  """
  @spec stop() :: :ok
  def stop do
    GenServer.stop(__MODULE__)
  end

  @doc """
  Gets all tracked paths.
  """
  @spec get_paths() :: [Path.t()]
  def get_paths do
    __MODULE__
    |> GenServer.call(:get_paths)
    |> Enum.to_list()
  end

  @doc """
  Puts a new tracked path.
  """
  @spec put_path(Path.t()) :: :ok
  def put_path(path) do
    GenServer.cast(__MODULE__, {:put_path, path})
  end

  @doc """
  Removes all tracked files and resets the tracker.
  """
  @spec cleanup_files() :: [Path.t()]
  def cleanup_files do
    __MODULE__
    |> GenServer.call(:cleanup_files)
    |> Enum.to_list()
  end

  # Callbacks

  @impl true
  def init(:ok), do: {:ok, @initial_value}

  @impl true
  def handle_cast({:put_path, path}, paths) do
    {:noreply, MapSet.put(paths, path)}
  end

  @impl true
  def handle_call(:get_paths, _from, paths) do
    {:reply, paths, paths}
  end

  def handle_call(:cleanup_files, _from, paths) do
    do_cleanup_files(paths)
    {:reply, paths, @initial_value}
  end

  @impl true
  def terminate(_reason, paths) do
    do_cleanup_files(paths)
  end

  defp do_cleanup_files(paths) do
    Enum.each(paths, fn path ->
      File.rm_rf!(path)
    end)
  end
end
