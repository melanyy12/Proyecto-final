defmodule Hackathon.Adapters.Persistencia.RepositorioProyectos do
  @archivo "data/proyectos.txt"

  def guardar(proyecto) do
    contenido = serializar(proyecto)
    File.mkdir_p!("data")
    File.write!(@archivo, contenido <> "\n", [:append])
    :ok
  rescue
    e -> {:error, "Error al guardar: #{inspect(e)}"}
  end

  def listar_todos do
    if File.exists?(@archivo) do
      proyectos =
        File.read!(@archivo)
        |> String.split("\n", trim: true)
        |> Enum.map(&deserializar/1)
        |> Enum.reject(&is_nil/1)
      {:ok, proyectos}
    else
      {:ok, []}
    end
  rescue
    e -> {:error, "Error al leer: #{inspect(e)}"}
  end

  def obtener(proyecto_id) do
    case listar_todos() do
      {:ok, proyectos} ->
        case Enum.find(proyectos, fn p -> p.id == proyecto_id end) do
          nil -> {:error, :no_encontrado}
          proyecto -> {:ok, proyecto}
        end
      error -> error
    end
  end

  def actualizar(proyecto) do
    case listar_todos() do
      {:ok, proyectos} ->
        proyectos_actualizados =
          Enum.map(proyectos, fn p ->
            if p.id == proyecto.id, do: proyecto, else: p
          end)
        reescribir_archivo(proyectos_actualizados)
      error -> error
    end
  end

  def filtrar_por_categoria(categoria) do
    case listar_todos() do
      {:ok, proyectos} ->
        filtrados = Enum.filter(proyectos, fn p -> p.categoria == categoria end)
        {:ok, filtrados}
      error -> error
    end
  end

  def filtrar_por_estado(estado) do
    case listar_todos() do
      {:ok, proyectos} ->
        filtrados = Enum.filter(proyectos, fn p -> p.estado == estado end)
        {:ok, filtrados}
      error -> error
    end
  end

  def obtener_por_equipo(equipo_id) do
    case listar_todos() do
      {:ok, proyectos} ->
        case Enum.find(proyectos, fn p -> p.equipo_id == equipo_id end) do
          nil -> {:error, :no_encontrado}
          proyecto -> {:ok, proyecto}
        end
      error -> error
    end
  end

  defp reescribir_archivo(proyectos) do
    contenido = Enum.map_join(proyectos, "\n", &serializar/1)
    File.write!(@archivo, contenido <> "\n")
    :ok
  rescue
    e -> {:error, "Error al actualizar: #{inspect(e)}"}
  end

  defp serializar(proyecto) do
    avances_json = proyecto.avances
      |> Enum.map(fn av -> "#{av.contenido}~~~#{DateTime.to_iso8601(av.fecha)}" end)
      |> Enum.join(";;")

    retro_json = proyecto.retroalimentacion
      |> Enum.map(fn ret -> "#{ret.mentor_id}~~~#{ret.comentario}~~~#{DateTime.to_iso8601(ret.fecha)}" end)
      |> Enum.join(";;")

    "#{proyecto.id}|#{proyecto.nombre}|#{proyecto.descripcion}|#{proyecto.categoria}|#{proyecto.equipo_id}|#{proyecto.estado}|#{avances_json}|#{retro_json}"
  end

  defp deserializar(linea) do
    case String.split(linea, "|", parts: 8) do
      [id, nombre, descripcion, categoria, equipo_id, estado, avances_str, retro_str] ->
        avances = if avances_str == "" do
          []
        else
          String.split(avances_str, ";;")
          |> Enum.map(fn av_str ->
            case String.split(av_str, "~~~") do
              [contenido, fecha_iso] ->
                {:ok, fecha, _} = DateTime.from_iso8601(fecha_iso)
                %{contenido: contenido, fecha: fecha}
              _ -> nil
            end
          end)
          |> Enum.reject(&is_nil/1)
        end

        retroalimentacion = if retro_str == "" do
          []
        else
          String.split(retro_str, ";;")
          |> Enum.map(fn ret_str ->
            case String.split(ret_str, "~~~") do
              [mentor_id, comentario, fecha_iso] ->
                {:ok, fecha, _} = DateTime.from_iso8601(fecha_iso)
                %{mentor_id: mentor_id, comentario: comentario, fecha: fecha}
              _ -> nil
            end
          end)
          |> Enum.reject(&is_nil/1)
        end

        %Hackathon.Domain.Proyecto{
          id: id,
          nombre: nombre,
          descripcion: descripcion,
          categoria: String.to_atom(categoria),
          equipo_id: equipo_id,
          estado: String.to_atom(estado),
          avances: avances,
          retroalimentacion: retroalimentacion,
          fecha_creacion: nil,
          fecha_actualizacion: nil
        }
      _ -> nil
    end
  end
end
