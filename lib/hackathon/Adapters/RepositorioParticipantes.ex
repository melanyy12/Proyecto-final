defmodule Hackathon.Adapters.Persistencia.RepositorioParticipantes do
  @archivo "data/participantes.txt"

  def guardar(participante) do
    contenido = serializar(participante)
    File.mkdir_p!("data")
    File.write!(@archivo, contenido <> "\n", [:append])
    :ok
  rescue
    e -> {:error, "Error al guardar: #{inspect(e)}"}
  end

  def listar_todos do
    if File.exists?(@archivo) do
      participantes =
        File.read!(@archivo)
        |> String.split("\n", trim: true)
        |> Enum.map(&deserializar/1)
        |> Enum.reject(&is_nil/1)

      {:ok, participantes}
    else
      {:ok, []}
    end
  rescue
    e -> {:error, "Error al leer: #{inspect(e)}"}
  end

  def obtener(participante_id) do
    case listar_todos() do
      {:ok, participantes} ->
        case Enum.find(participantes, fn p -> p.id == participante_id end) do
          nil -> {:error, :no_encontrado}
          participante -> {:ok, participante}
        end

      error ->
        error
    end
  end

  def buscar_por_correo(correo) do
    case listar_todos() do
      {:ok, participantes} ->
        case Enum.find(participantes, fn p -> String.downcase(p.correo) == String.downcase(correo) end) do
          nil -> {:error, :no_encontrado}
          participante -> {:ok, participante}
        end

      error ->
        error
    end
  end

  def actualizar(participante) do
    case listar_todos() do
      {:ok, participantes} ->
        participantes_actualizados =
          Enum.map(participantes, fn p ->
            if p.id == participante.id, do: participante, else: p
          end)

        reescribir_archivo(participantes_actualizados)

      error ->
        error
    end
  end

  defp reescribir_archivo(participantes) do
    contenido = Enum.map_join(participantes, "\n", &serializar/1)
    File.write!(@archivo, contenido <> "\n")
    :ok
  rescue
    e -> {:error, "Error al actualizar: #{inspect(e)}"}
  end

  defp serializar(participante) do
    habilidades_str = Enum.join(participante.habilidades, ",")
    equipo_id_str = participante.equipo_id || ""
    password_hash_str = participante.password_hash || ""

    "#{participante.id}|#{participante.nombre}|#{participante.correo}|#{habilidades_str}|#{equipo_id_str}|#{password_hash_str}"
  end

  defp deserializar(linea) do
    case String.split(linea, "|") do
      [id, nombre, correo, habilidades_str, equipo_id_str] ->
        # Versión antigua sin password_hash
        habilidades = if habilidades_str == "", do: [], else: String.split(habilidades_str, ",")
        equipo_id = if equipo_id_str == "", do: nil, else: equipo_id_str

        %Hackathon.Domain.Participante{
          id: id,
          nombre: nombre,
          correo: correo,
          habilidades: habilidades,
          equipo_id: equipo_id,
          password_hash: nil
        }

      [id, nombre, correo, habilidades_str, equipo_id_str, password_hash_str] ->
        # Versión nueva con password_hash
        habilidades = if habilidades_str == "", do: [], else: String.split(habilidades_str, ",")
        equipo_id = if equipo_id_str == "", do: nil, else: equipo_id_str
        password_hash = if password_hash_str == "", do: nil, else: password_hash_str

        %Hackathon.Domain.Participante{
          id: id,
          nombre: nombre,
          correo: correo,
          habilidades: habilidades,
          equipo_id: equipo_id,
          password_hash: password_hash
        }

      _ ->
        nil
    end
  end
end
