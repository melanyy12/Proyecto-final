defmodule Hackathon.Adapters.Persistencia.RepositorioMentores do
  @archivo "data/mentores.txt"

  def guardar(mentor) do
    contenido = serializar(mentor)
    File.mkdir_p!("data")
    File.write!(@archivo, contenido <> "\n", [:append])
    :ok
  rescue
    e -> {:error, "Error al guardar: #{inspect(e)}"}
  end

  def listar_todos do
    if File.exists?(@archivo) do
      mentores =
        File.read!(@archivo)
        |> String.split("\n", trim: true)
        |> Enum.map(&deserializar/1)
        |> Enum.reject(&is_nil/1)
      {:ok, mentores}
    else
      {:ok, []}
    end
  rescue
    e -> {:error, "Error al leer: #{inspect(e)}"}
  end

  def obtener(mentor_id) do
    case listar_todos() do
      {:ok, mentores} ->
        case Enum.find(mentores, fn m -> m.id == mentor_id end) do
          nil -> {:error, :no_encontrado}
          mentor -> {:ok, mentor}
        end
      error -> error
    end
  end

  def actualizar(mentor) do
    case listar_todos() do
      {:ok, mentores} ->
        mentores_actualizados =
          Enum.map(mentores, fn m ->
            if m.id == mentor.id, do: mentor, else: m
          end)
        reescribir_archivo(mentores_actualizados)
      error -> error
    end
  end

  defp reescribir_archivo(mentores) do
    contenido = Enum.map_join(mentores, "\n", &serializar/1)
    File.write!(@archivo, contenido <> "\n")
    :ok
  rescue
    e -> {:error, "Error al actualizar: #{inspect(e)}"}
  end

  defp serializar(mentor) do
    equipos_str = Enum.join(mentor.equipos_asignados, ",")
    "#{mentor.id}|#{mentor.nombre}|#{mentor.especialidad}|#{mentor.correo}|#{equipos_str}|#{mentor.disponible}|#{mentor.max_equipos}"
  end

  defp deserializar(linea) do
    case String.split(linea, "|") do
      [id, nombre, especialidad, correo, equipos_str, disponible, max_equipos] ->
        equipos = if equipos_str == "", do: [], else: String.split(equipos_str, ",")

        %Hackathon.Domain.Mentor{
          id: id,
          nombre: nombre,
          especialidad: especialidad,
          correo: correo,
          equipos_asignados: equipos,
          disponible: disponible == "true",
          max_equipos: String.to_integer(max_equipos)
        }
      _ -> nil
    end
  end
end
