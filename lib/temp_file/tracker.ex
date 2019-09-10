defmodule TempFile.Tracker do
  @moduledoc """
  A server that tracks all temp paths generated during its runtime. Can be used
  to cleanup all tracked files when needed. Automatically clears all tracked
  files when the server terminates.

  ## Usage in Tests

  TODO
  """

  use GenServer

  @initial_state %{}

  @doc """
  Starts the tracker.
  """
  @spec start_link(Keyword.t()) :: TempFile.tracker()
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
  Enables temp file tracking for the current process.
  """
  @spec enable_tracker() :: :ok
  def enable_tracker(pid \\ self()) do
    GenServer.cast(__MODULE__, {:enable_tracker, pid})
  end

  @doc """
  Disables temp file tracking for the current process.
  """
  @spec disable_tracker(pid) :: :ok
  def disable_tracker(pid \\ self()) do
    GenServer.cast(__MODULE__, {:disable_tracker, pid})
  end

  @doc """
  Gets all tracked paths.
  """
  @spec get_paths(pid) :: [Path.t()]
  def get_paths(pid \\ self()) do
    __MODULE__
    |> GenServer.call({:get_paths, pid})
    |> Enum.to_list()
  end

  @doc """
  Puts a new tracked path.
  """
  @spec put_path(pid, Path.t()) :: :ok
  def put_path(pid \\ self(), path) do
    GenServer.cast(__MODULE__, {:put_path, pid, path})
  end

  @doc """
  Removes all tracked files and resets the tracker.
  """
  @spec cleanup_files(pid) :: [Path.t()]
  def cleanup_files(pid \\ self()) do
    __MODULE__
    |> GenServer.call({:cleanup_files, pid})
    |> Enum.to_list()
  end

  def cleanup_all_files do
    __MODULE__
    |> GenServer.call(:cleanup_all_files)
    |> Enum.to_list()
  end

  # Callbacks

  @impl true
  def init(:ok), do: {:ok, @initial_state}

  @impl true
  def handle_cast({:enable_tracker, pid}, state) do
    {:noreply, Map.put_new(state, pid, MapSet.new())}
  end

  def handle_cast({:disable_tracker, pid}, state) do
    {:noreply, Map.delete(state, pid)}
  end

  def handle_cast({:put_path, pid, path}, state) do
    if Map.has_key?(state, pid) do
      {:noreply, Map.update!(state, pid, &MapSet.put(&1, path))}
    else
      {:noreply, state}
    end
  end

  @impl true
  def handle_call({:get_paths, pid}, _from, state) do
    paths = Map.get(state, pid, MapSet.new())
    {:reply, paths, state}
  end

  def handle_call({:cleanup_files, pid}, _from, state) do
    case Map.fetch(state, pid) do
      {:ok, paths} ->
        do_cleanup_files(paths)
        {:reply, paths, Map.put(state, pid, MapSet.new())}

      :error ->
        {:reply, MapSet.new(), state}
    end
  end

  def handle_call(:cleanup_all_files, _from, state) do
    paths = do_cleanup_all_files(state)
    {:reply, paths, @initial_state}
  end

  @impl true
  def terminate(_reason, state) do
    do_cleanup_all_files(state)
  end

  defp do_cleanup_files(paths) do
    Enum.each(paths, fn path ->
      File.rm_rf!(path)
    end)
  end

  defp do_cleanup_all_files(state) do
    paths = for {_, paths} <- state, path <- paths, into: MapSet.new(), do: path
    do_cleanup_files(paths)
    paths
  end
end
