defmodule TempFile.TestHelper do
  import ExUnit.Callbacks

  alias TempFile.Tracker

  @spec cleanup_temp_files_on_exit(term) :: :ok
  def cleanup_temp_files_on_exit(context \\ %{}) do
    pid = self()
    Tracker.enable_tracker(pid)

    on_exit(fn ->
      if context[:temp_files_tracking_global_mode] do
        Tracker.cleanup_all_files()
      else
        Tracker.cleanup_files(pid)
      end
    end)

    :ok
  end

  def set_temp_files_tracking_global(_context \\ %{}) do
    {:ok, temp_files_tracking_global_mode: true}
  end

  def set_temp_files_tracking_private(_context \\ %{}) do
    {:ok, temp_files_tracking_global_mode: false}
  end

  def set_temp_files_tracking_from_context(%{async: true} = context) do
    set_temp_files_tracking_private(context)
  end

  def set_temp_files_tracking_from_context(context) do
    set_temp_files_tracking_global(context)
  end
end
