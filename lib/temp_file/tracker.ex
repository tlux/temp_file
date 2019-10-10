defmodule TempFile.Tracker do
  @moduledoc false

  use GenServer

  @spec start_link(Keyword.t()) :: GenServer.on_start()
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @spec stop(term) :: :ok
  def stop(reason \\ :normal) do
    GenServer.stop(__MODULE__, reason)
  end

  @spec tracker_enabled?() :: boolean
  def tracker_enabled? do
    GenServer.call(__MODULE__, :tracker_enabled?)
  end

  @spec toggle_tracker(boolean) :: :ok
  def toggle_tracker(enabled) do
    GenServer.call(__MODULE__, {:toggle_tracker, enabled})
  end

  @spec get_paths() :: [Path.t()]
  def get_paths do
    GenServer.call(__MODULE__, :get_paths)
  end

  @spec put_path(Path.t()) :: :ok | :error
  def put_path(path) do
    GenServer.call(__MODULE__, {:put_path, path})
  end

  @spec cleanup_files() :: :ok
  def cleanup_files do
    GenServer.call(__MODULE__, :cleanup_files)
  end

  # Callbacks

  @impl true
  def init(opts) do
    enabled? =
      Keyword.get_lazy(opts, :enabled, fn ->
        Application.get_env(:temp_file, :tracker_enabled?, false)
      end)

    {:ok, %{enabled?: enabled?, paths: MapSet.new()}}
  end

  @impl true
  def terminate(_reason, state) do
    do_cleanup_files(state.paths)
  end

  @impl true
  def handle_call(:tracker_enabled?, _from, state) do
    {:reply, state.enabled?, state}
  end

  def handle_call({:toggle_tracker, enabled}, _from, state) do
    {:reply, :ok, put_in(state.enabled?, enabled)}
  end

  def handle_call(:get_paths, _from, state) do
    {:reply, Enum.to_list(state.paths), state}
  end

  def handle_call({:put_path, path}, _from, %{enabled?: true} = state) do
    {:reply, :ok, %{state | paths: MapSet.put(state.paths, path)}}
  end

  def handle_call({:put_path, _path}, _from, state) do
    {:reply, :error, state}
  end

  def handle_call(:cleanup_files, _from, state) do
    do_cleanup_files(state.paths)
    {:reply, :ok, %{state | paths: MapSet.new()}}
  end

  defp do_cleanup_files(paths) do
    Enum.each(paths, &File.rm_rf!/1)
  end
end
