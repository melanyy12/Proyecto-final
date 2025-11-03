defmodule Hackathon.Domain.Equipo do
  @moduledoc """
  Entidad que representa un equipo de la hackathon
  """

  @enforce_keys [:id, :nombre]
  defstruct [
    :id,
    :nombre,
    :tema,
    :categoria,
    miembros: [],
    proyecto_id: nil,
    activo: true,
    fecha_creacion: nil,
    max_miembros: 6
  ]

  def nuevo(id, nombre, tema, categoria) do
    %__MODULE__{
      id: id,
      nombre: nombre,
      tema: tema,
      categoria: categoria,
      fecha_creacion: DateTime.utc_now()
    }
  end

  def agregar_miembro(%__MODULE__{} = equipo, participante_id) do
    cond do
      participante_id in equipo.miembros ->
        {:error, "Participante ya esta en el equipo"}

      length(equipo.miembros) >= equipo.max_miembros ->
        {:error, "Equipo lleno (maximo #{equipo.max_miembros} miembros)"}

      true ->
        {:ok, %{equipo | miembros: [participante_id | equipo.miembros]}}
    end
  end

  def remover_miembro(%__MODULE__{} = equipo, participante_id) do
    nuevos_miembros = Enum.reject(equipo.miembros, fn id -> id == participante_id end)
    %{equipo | miembros: nuevos_miembros}
  end

  def asignar_proyecto(%__MODULE__{} = equipo, proyecto_id) do
    %{equipo | proyecto_id: proyecto_id}
  end

  def completo?(%__MODULE__{} = equipo) do
    length(equipo.miembros) >= equipo.max_miembros
  end

  def desactivar(%__MODULE__{} = equipo) do
    %{equipo | activo: false}
  end
end
