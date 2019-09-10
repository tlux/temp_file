defmodule TempFile.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      TempFile.Tracker
    ]

    Supervisor.start_link(
      children,
      strategy: :one_for_one,
      name: AppMonitoring.Supervisor
    )
  end
end
