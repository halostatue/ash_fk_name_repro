defmodule AshFkNameRepro.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [AshFkNameRepro.Repo]

    opts = [strategy: :one_for_one, name: AshFkNameRepro.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
