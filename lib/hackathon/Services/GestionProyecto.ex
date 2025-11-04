defmodule Hackathon.Services.GestionProyectos do
  @moduledoc """
  Servicio para gestionar proyectos de la hackathon
  """

  alias Hackathon.Domain.Proyecto
  alias Hackathon.Domain.ValidadorProyecto
  alias Hackathon.Adapters.Persistencia.RepositorioProyectos

  @doc """
  Registra un nuevo proyecto
  """
  def registrar_proyecto(attrs) do
    with {:ok, _} <- ValidadorProyecto.validar_proyecto(attrs),
         proyecto <- Proyecto.nuevo(
           generar_id(),
           attrs.nombre,
           attrs.descripcion,
           attrs.categoria,
           attrs.equipo_id
         ),
         :ok <- RepositorioProyectos.guardar(proyecto) do
      {:ok, proyecto}
    else
      {:error, errores} when is_list(errores) ->
        {:error, Enum.join(errores, ", ")}
      {:error, razon} ->
        {:error, razon}
    end
  end
@doc """
Elimina un proyecto
"""
def eliminar_proyecto(proyecto_id) do
  case listar_proyectos() do
    {:ok, proyectos} ->
      proyectos_filtrados = Enum.reject(proyectos, fn p -> p.id == proyecto_id end)
      reescribir_archivo_proyectos(proyectos_filtrados)
      {:ok, :eliminado}
    error -> error
  end
end

defp reescribir_archivo_proyectos(proyectos) do
  alias Hackathon.Adapters.Persistencia.RepositorioProyectos
  File.rm("data/proyectos.txt")
  Enum.each(proyectos, fn p ->
    RepositorioProyectos.guardar(p)
  end)
  :ok
end
  @doc """
  Agrega un avance a un proyecto
  """
  def agregar_avance(proyecto_id, avance) do
    if ValidadorProyecto.avance_valido?(avance) do
      with {:ok, proyecto} <- RepositorioProyectos.obtener(proyecto_id),
           proyecto_actualizado <- Proyecto.agregar_avance(proyecto, avance),
           :ok <- RepositorioProyectos.actualizar(proyecto_actualizado) do
        {:ok, proyecto_actualizado}
      else
        {:error, razon} -> {:error, razon}
      end
    else
      {:error, "Avance no puede estar vacío"}
    end
  end

  @doc """
  Agrega retroalimentación de un mentor a un proyecto
  """
  def agregar_retroalimentacion(proyecto_id, mentor_id, comentario) do
    with {:ok, proyecto} <- RepositorioProyectos.obtener(proyecto_id),
         proyecto_actualizado <- Proyecto.agregar_retroalimentacion(proyecto, mentor_id, comentario),
         :ok <- RepositorioProyectos.actualizar(proyecto_actualizado) do
      {:ok, proyecto_actualizado}
    else
      {:error, razon} -> {:error, razon}
    end
  end

  @doc """
  Cambia el estado de un proyecto
  """
  def cambiar_estado(proyecto_id, nuevo_estado) do
    with {:ok, proyecto} <- RepositorioProyectos.obtener(proyecto_id),
         resultado <- Proyecto.cambiar_estado(proyecto, nuevo_estado),
         {:ok, proyecto_actualizado} <- validar_resultado_cambio(resultado),
         :ok <- RepositorioProyectos.actualizar(proyecto_actualizado) do
      {:ok, proyecto_actualizado}
    else
      {:error, razon} -> {:error, razon}
    end
  end

  @doc """
  Consulta proyectos por categoría
  """
  def consultar_por_categoria(categoria) do
    if ValidadorProyecto.categoria_valida?(categoria) do
      RepositorioProyectos.filtrar_por_categoria(categoria)
    else
      {:error, "Categoría inválida"}
    end
  end

  @doc """
  Consulta proyectos por estado
  """
  def consultar_por_estado(estado) do
    RepositorioProyectos.filtrar_por_estado(estado)
  end

  @doc """
  Lista todos los proyectos
  """
  def listar_proyectos do
    RepositorioProyectos.listar_todos()
  end

  @doc """
  Obtiene un proyecto por su ID
  """
  def obtener_proyecto(proyecto_id) do
    RepositorioProyectos.obtener(proyecto_id)
  end

  @doc """
  Obtiene el proyecto de un equipo específico
  """
  def obtener_por_equipo(equipo_id) do
    RepositorioProyectos.obtener_por_equipo(equipo_id)
  end

  @doc """
  Obtiene el último avance de un proyecto
  """
  def obtener_ultimo_avance(proyecto_id) do
    case RepositorioProyectos.obtener(proyecto_id) do
      {:ok, proyecto} ->
        avance = Proyecto.ultimo_avance(proyecto)
        {:ok, avance}
      error -> error
    end
  end

  @doc """
  Cuenta los avances de un proyecto
  """
  def contar_avances(proyecto_id) do
    case RepositorioProyectos.obtener(proyecto_id) do
      {:ok, proyecto} ->
        cantidad = Proyecto.cantidad_avances(proyecto)
        {:ok, cantidad}
      error -> error
    end
  end

  # Funciones privadas

  defp validar_resultado_cambio(%Proyecto{} = proyecto), do: {:ok, proyecto}
  defp validar_resultado_cambio({:error, razon}), do: {:error, razon}

  defp generar_id, do: :crypto.strong_rand_bytes(16) |> Base.encode16(case: :lower)
end
