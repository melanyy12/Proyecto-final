defmodule Hackathon.Adapters.Persistencia.RepositorioMensajes do
  @archivo "data/mensajes.txt"

  def guardar(mensaje) do
    contenido = serializar(mensaje)
    File.mkdir_p!("data")
    File.write!(@archivo, contenido <> "\n", [:append])
    :ok
  rescue
    e -> {:error, "Error al guardar mensaje: #{inspect(e)}"}
  end

  def obtener_por_canal(canal) do
    if File.exists?(@archivo) do
      mensajes =
        File.read!(@archivo)
        |> String.split("\n", trim: true)
        |> Enum.map(&deserializar/1)
        |> Enum.reject(&is_nil/1)
        |> Enum.filter(fn m -> m.canal == canal end)
        |> Enum.sort_by(& &1.fecha, DateTime)

      {:ok, mensajes}
    else
      {:ok, []}
    end
  rescue
    e -> {:error, "Error al leer mensajes: #{inspect(e)}"}
  end

  def listar_todos do
    if File.exists?(@archivo) do
      mensajes =
        File.read!(@archivo)
        |> String.split("\n", trim: true)
        |> Enum.map(&deserializar/1)
        |> Enum.reject(&is_nil/1)
      {:ok, mensajes}
    else
      {:ok, []}
    end
  rescue
    e -> {:error, "Error al leer: #{inspect(e)}"}
  end

  defp serializar(mensaje) do
    fecha_str = if mensaje.fecha, do: DateTime.to_iso8601(mensaje.fecha), else: ""
    tipo_str = mensaje.tipo || :normal
    "#{mensaje.id}|#{mensaje.emisor_id}|#{mensaje.contenido}|#{mensaje.canal}|#{tipo_str}|#{fecha_str}"
  end

  defp deserializar(linea) do
    case String.split(linea, "|") do
      [id, emisor_id, contenido, canal, tipo_str, fecha_str] ->
        fecha = if fecha_str != "" do
          case DateTime.from_iso8601(fecha_str) do
            {:ok, dt, _} -> dt
            _ -> DateTime.utc_now()
          end
        else
          DateTime.utc_now()
        end

        %Hackathon.Domain.Mensaje{
          id: id,
          emisor_id: emisor_id,
          contenido: contenido,
          canal: canal,
          tipo: String.to_atom(tipo_str),
          fecha: fecha
        }
      _ -> nil
    end
  end
end
