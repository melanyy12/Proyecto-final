defmodule Hackathon.Domain.Mentor do
  @moduledoc """
  Entidad que representa a un mentor de la hackathon
  """

  @enforce_keys [:id, :nombre, :especialidad]
  defstruct [
    :id,
    :nombre,
    :especialidad,
    :correo,
    :password_hash,
    equipos_asignados: [],
    disponible: true,
    max_equipos: 3
  ]

  def nuevo(id, nombre, especialidad, correo, password_hash \\ nil) do
    %__MODULE__{
      id: id,
      nombre: nombre,
      especialidad: especialidad,
      correo: correo,
      password_hash: password_hash
    }
  end

  def asignar_equipo(%__MODULE__{} = mentor, equipo_id) do
    cond do
      equipo_id in mentor.equipos_asignados ->
        {:error, "Equipo ya asignado a este mentor"}

      length(mentor.equipos_asignados) >= mentor.max_equipos ->
        {:error, "Mentor tiene el máximo de equipos asignados (#{mentor.max_equipos})"}

      true ->
        {:ok, %{mentor | equipos_asignados: [equipo_id | mentor.equipos_asignados]}}
    end
  end

  def remover_equipo(%__MODULE__{} = mentor, equipo_id) do
    nuevos_equipos = Enum.reject(mentor.equipos_asignados, fn id -> id == equipo_id end)
    %{mentor | equipos_asignados: nuevos_equipos}
  end

  def tiene_capacidad?(%__MODULE__{} = mentor) do
    length(mentor.equipos_asignados) < mentor.max_equipos
  end

  def cambiar_disponibilidad(%__MODULE__{} = mentor, disponible) do
    %{mentor | disponible: disponible}
  end

  @doc """
  Hashea una contraseña usando SHA256
  """
  def hashear_password(password) when is_binary(password) do
    :crypto.hash(:sha256, password)
    |> Base.encode64()
  end

  @doc """
  Verifica si una contraseña coincide con el hash almacenado
  """
  def verificar_password(password, password_hash) do
    hashear_password(password) == password_hash
  end
end
