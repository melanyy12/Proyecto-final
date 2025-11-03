defmodule Hackathon.Application do
  @moduledoc """
  Aplicación OTP con supervisión de servicios críticos
  """
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Registry para canales de chat dinámicos
      {Registry, keys: :unique, name: Hackathon.CanalRegistry},

      # Sistema de Chat principal
      {Hackathon.Services.SistemaChat, []},

      # Supervisor dinámico para canales individuales
      {DynamicSupervisor, strategy: :one_for_one, name: Hackathon.CanalesSupervisor},

      # Tarea periódica para limpiar sesiones expiradas
      {Task, fn -> iniciar_limpieza_periodica() end}
    ]

    opts = [strategy: :one_for_one, name: Hackathon.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp iniciar_limpieza_periodica do
    # Limpiar sesiones cada hora
    Process.sleep(3600 * 1000)
    Hackathon.Services.Autenticacion.limpiar_sesiones_expiradas()
    iniciar_limpieza_periodica()
  end
end

