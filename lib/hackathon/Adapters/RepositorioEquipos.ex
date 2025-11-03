defmodule Hackathon.Adapters.Persistencia.RepositorioEquipos do
  @archivo "data/equipos.txt"

  def guardar(equipo) do
    contenido = serializar(equipo)
    File.mkdir_p!("data")
    File.write!(@archivo, contenido <> "\n", [:append])
    :ok
  rescue
    e -> {:error, "Error al guardar: #{inspect(e)}"}
  end

  def listar_todos do
    if File.exists?(@archivo) do
      equipos =
        File.read!(@archivo)
        |> String.split("\n", trim: true)
        |> Enum.map(&deserializar/1)
        |> Enum.reject(&is_nil/1)
      {:ok, equipos}
    else
      {:ok, []}
    end
  rescue
    e -> {:error, "Error al leer: #{inspect(e)}"}
  end

  def obtener(equipo_id) do
    case listar_todos() do
      {:ok, equipos} ->
        case Enum.find(equipos, fn e -> e.id == equipo_id end) do
          nil -> {:error, :no_encontrado}
          equipo -> {:ok, equipo}
        end
      error -> error
    end
  end

  def buscar_por_nombre(nombre) do
    case listar_todos() do
      {:ok, equipos} ->
        case Enum.find(equipos, fn e -> String.downcase(e.nombre) == String.downcase(nombre) end) do
          nil -> {:error, :no_encontrado}
          equipo -> {:ok, equipo}
        end
      error -> error
    end
  end

  def actualizar(equipo) do
    case listar_todos() do
      {:ok, equipos} ->
        equipos_actualizados =
          Enum.map(equipos, fn e ->
            if e.id == equipo.id, do: equipo, else: e
          end)
        reescribir_archivo(equipos_actualizados)
      error -> error
    end
  end

  defp reescribir_archivo(equipos) do
    contenido = Enum.map_join(equipos, "\n", &serializar/1)
    File.write!(@archivo, contenido <> "\n")
    :ok
  rescue
    e -> {:error, "Error al actualizar: #{inspect(e)}"}
  end

  defp serializar(equipo) do
    miembros_str = Enum.join(equipo.miembros, ",")
    "#{equipo.id}|#{equipo.nombre}|#{equipo.tema}|#{equipo.categoria}|#{miembros_str}|#{equipo.activo}"
  end

  defp deserializar(linea) do
    case String.split(linea, "|") do
      [id, nombre, tema, categoria, miembros_str, activo] ->
        miembros = if miembros_str == "", do: [], else: String.split(miembros_str, ",")
        %Hackathon.Domain.Equipo{
          id: id,
          nombre: nombre,
          tema: tema,
          categoria: String.to_atom(categoria),
          miembros: miembros,
          activo: activo == "true",
          proyecto_id: nil,
          fecha_creacion: nil,
          max_miembros: 6
        }
      _ -> nil
    end
  end
end
