defmodule Hackathon.Services.GestionMentores do
  @moduledoc """
  Servicio para gestionar mentores de la hackathon
  """

  alias Hackathon.Domain.Mentor
  alias Hackathon.Adapters.Persistencia.RepositorioMentores

  def registrar_mentor(attrs) do
    mentor = Mentor.nuevo(
      generar_id(),
      attrs.nombre,
      attrs.especialidad,
      attrs.correo
    )

    case RepositorioMentores.guardar(mentor) do
      :ok -> {:ok, mentor}
      error -> error
    end
  end

  def asignar_a_equipo(mentor_id, equipo_id) do
    with {:ok, mentor} <- RepositorioMentores.obtener(mentor_id),
         {:ok, mentor_actualizado} <- Mentor.asignar_equipo(mentor, equipo_id),
         :ok <- RepositorioMentores.actualizar(mentor_actualizado) do
      {:ok, mentor_actualizado}
    else
      {:error, razon} -> {:error, razon}
    end
  end

  def listar_mentores do
    RepositorioMentores.listar_todos()
  end

  def obtener_mentor(mentor_id) do
    RepositorioMentores.obtener(mentor_id)
  end

  def listar_disponibles do
    case listar_mentores() do
      {:ok, mentores} ->
        disponibles = Enum.filter(mentores, fn m -> Mentor.tiene_capacidad?(m) end)
        {:ok, disponibles}
      error -> error
    end
  end

  defp generar_id do
    :crypto.strong_rand_bytes(8) |> Base.encode16(case: :lower)
  end
end
