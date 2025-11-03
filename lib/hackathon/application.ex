defmodule Hackathon.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Hackathon.Services.SistemaChat, []}
    ]
    opts = [strategy: :one_for_one, name: Hackathon.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
