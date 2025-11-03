defmodule Hackathon.Services.GestionEquipos do
  @moduledoc """
  Servicio para gestionar equipos de la hackathon
  """

  alias Hackathon.Domain.Equipo
  alias Hackathon.Domain.ValidadorEquipo
  alias Hackathon.Adapters.Persistencia.RepositorioEquipos

  @doc """
  Crea un nuevo equipo
  """
  def crear_equipo(attrs) do
    with {:ok, _} <- ValidadorEquipo.validar_equipo(attrs),
         equipo <- Equipo.nuevo(
           generar_id(),
           attrs.nombre,
           attrs.tema,
           attrs.categoria
         ),
         :ok <- RepositorioEquipos.guardar(equipo) do
      {:ok, equipo}
    else
      {:error, errores} when is_list(errores) ->
        {:error, Enum.join(errores, ", ")}
      {:error, razon} ->
        {:error, razon}
    end
  end

  @doc """
  Agrega un miembro a un equipo
  """
  def agregar_miembro(equipo_id, participante_id) do
    with {:ok, equipo} <- RepositorioEquipos.obtener(equipo_id),
         {:ok, equipo_actualizado} <- Equipo.agregar_miembro(equipo, participante_id),
         :ok <- RepositorioEquipos.actualizar(equipo_actualizado) do
      {:ok, equipo_actualizado}
    else
      {:error, razon} -> {:error, razon}
    end
  end

  @doc """
  Remueve un miembro de un equipo
  """
  def remover_miembro(equipo_id, participante_id) do
    with {:ok, equipo} <- RepositorioEquipos.obtener(equipo_id),
         equipo_actualizado <- Equipo.remover_miembro(equipo, participante_id),
         :ok <- RepositorioEquipos.actualizar(equipo_actualizado) do
      {:ok, equipo_actualizado}
    else
      {:error, razon} -> {:error, razon}
    end
  end

  @doc """
  Lista todos los equipos registrados
  """
  def listar_equipos do
    RepositorioEquipos.listar_todos()
  end

  @doc """
  Lista solo los equipos activos
  """
  def listar_equipos_activos do
    case RepositorioEquipos.listar_todos() do
      {:ok, equipos} ->
        activos = Enum.filter(equipos, fn e -> e.activo end)
        {:ok, activos}
      error -> error
    end
  end

  @doc """
  Obtiene un equipo por su ID
  """
  def obtener_equipo(equipo_id) do
    RepositorioEquipos.obtener(equipo_id)
  end

  @doc """
  Obtiene un equipo por su nombre
  """
  def buscar_por_nombre(nombre) do
    RepositorioEquipos.buscar_por_nombre(nombre)
  end

  @doc """
  Asigna un proyecto a un equipo
  """
  def asignar_proyecto(equipo_id, proyecto_id) do
    with {:ok, equipo} <- RepositorioEquipos.obtener(equipo_id),
         equipo_actualizado <- Equipo.asignar_proyecto(equipo, proyecto_id),
         :ok <- RepositorioEquipos.actualizar(equipo_actualizado) do
      {:ok, equipo_actualizado}
    else
      {:error, razon} -> {:error, razon}
    end
  end

  @doc """
  Desactiva un equipo
  """
  def desactivar_equipo(equipo_id) do
    with {:ok, equipo} <- RepositorioEquipos.obtener(equipo_id),
         equipo_desactivado <- Equipo.desactivar(equipo),
         :ok <- RepositorioEquipos.actualizar(equipo_desactivado) do
      {:ok, equipo_desactivado}
    else
      {:error, razon} -> {:error, razon}
    end
  end

  defp generar_id, do: :crypto.strong_rand_bytes(16) |> Base.encode16(case: :lower)
end
