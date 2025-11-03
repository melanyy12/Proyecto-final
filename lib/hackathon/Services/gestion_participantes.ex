defmodule Hackathon.Services.GestionParticipantes do
  @moduledoc """
  Servicio para gestionar participantes de la hackathon
  """

  alias Hackathon.Domain.Participante
  alias Hackathon.Domain.ValidadorParticipante
  alias Hackathon.Adapters.Persistencia.RepositorioParticipantes

  def registrar_participante(attrs) do
    with {:ok, _} <- ValidadorParticipante.validar_participante(attrs),
         participante <- Participante.nuevo(
           generar_id(),
           attrs.nombre,
           attrs.correo,
           attrs[:habilidades] || []
         ),
         :ok <- RepositorioParticipantes.guardar(participante) do
      {:ok, participante}
    else
      {:error, errores} when is_list(errores) ->
        {:error, Enum.join(errores, ", ")}
      {:error, razon} ->
        {:error, razon}
    end
  end

  def unirse_a_equipo(participante_id, equipo_id) do
    alias Hackathon.Services.GestionEquipos

    with {:ok, participante} <- RepositorioParticipantes.obtener(participante_id),
         {:ok, _equipo} <- GestionEquipos.agregar_miembro(equipo_id, participante_id),
         participante_actualizado <- Participante.asignar_equipo(participante, equipo_id),
         :ok <- RepositorioParticipantes.actualizar(participante_actualizado) do
      {:ok, participante_actualizado}
    else
      {:error, razon} -> {:error, razon}
    end
  end

  def listar_participantes do
    RepositorioParticipantes.listar_todos()
  end

  def obtener_participante(participante_id) do
    RepositorioParticipantes.obtener(participante_id)
  end

  def buscar_por_correo(correo) do
    RepositorioParticipantes.buscar_por_correo(correo)
  end

  def listar_por_equipo(equipo_id) do
    case listar_participantes() do
      {:ok, participantes} ->
        filtrados = Enum.filter(participantes, fn p -> p.equipo_id == equipo_id end)
        {:ok, filtrados}
      error -> error
    end
  end

  defp generar_id do
    :crypto.strong_rand_bytes(8) |> Base.encode16(case: :lower)
  end
end
