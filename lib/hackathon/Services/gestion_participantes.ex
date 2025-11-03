defmodule Hackathon.Services.GestionParticipantes do
  @moduledoc """
  Servicio para gestionar participantes de la hackathon
  """

  alias Hackathon.Domain.Participante
  alias Hackathon.Domain.ValidadorParticipante
  alias Hackathon.Adapters.Persistencia.RepositorioParticipantes

  @doc """
  Registra un nuevo participante con contraseña
  """
  def registrar_participante(attrs) do
    with {:ok, _} <- ValidadorParticipante.validar_participante(attrs),
         {:ok, _} <- validar_password(attrs[:password]),
         password_hash <- Participante.hashear_password(attrs[:password]),
         participante <- Participante.nuevo(
           generar_id(),
           attrs.nombre,
           attrs.correo,
           attrs[:habilidades] || [],
           password_hash
         ),
         :ok <- RepositorioParticipantes.guardar(participante) do
      {:ok, participante}
    else
      {:error, errores} when is_list(errores) ->
        {:error, Enum.join(errores, ", ")}

      {:error, razon} ->
        {:error, razon}
    end
  end

  @doc """
  Une un participante a un equipo
  """
  def unirse_a_equipo(participante_id, equipo_id) do
    alias Hackathon.Services.GestionEquipos

    with {:ok, participante} <- RepositorioParticipantes.obtener(participante_id),
         {:ok, _equipo} <- GestionEquipos.agregar_miembro(equipo_id, participante_id),
         participante_actualizado <- Participante.asignar_equipo(participante, equipo_id),
         :ok <- RepositorioParticipantes.actualizar(participante_actualizado) do
      {:ok, participante_actualizado}
    else
      {:error, razon} -> {:error, razon}
    end
  end

  @doc """
  Lista todos los participantes
  """
  def listar_participantes do
    RepositorioParticipantes.listar_todos()
  end

  @doc """
  Obtiene un participante por su ID
  """
  def obtener_participante(participante_id) do
    RepositorioParticipantes.obtener(participante_id)
  end

  @doc """
  Busca un participante por correo
  """
  def buscar_por_correo(correo) do
    RepositorioParticipantes.buscar_por_correo(correo)
  end

  @doc """
  Lista participantes de un equipo específico
  """
  def listar_por_equipo(equipo_id) do
    case listar_participantes() do
      {:ok, participantes} ->
        filtrados = Enum.filter(participantes, fn p -> p.equipo_id == equipo_id end)
        {:ok, filtrados}

      error ->
        error
    end
  end

  @doc """
  Cambia la contraseña de un participante
  """
  def cambiar_password(participante_id, password_actual, password_nueva) do
    with {:ok, participante} <- RepositorioParticipantes.obtener(participante_id),
         true <- Participante.verificar_password(password_actual, participante.password_hash),
         {:ok, _} <- validar_password(password_nueva),
         password_hash <- Participante.hashear_password(password_nueva),
         participante_actualizado <- %{participante | password_hash: password_hash},
         :ok <- RepositorioParticipantes.actualizar(participante_actualizado) do
      {:ok, participante_actualizado}
    else
      false ->
        {:error, "Contraseña actual incorrecta"}

      {:error, razon} ->
        {:error, razon}
    end
  end

  # Funciones privadas

  defp generar_id do
    :crypto.strong_rand_bytes(8) |> Base.encode16(case: :lower)
  end

  defp validar_password(nil), do: {:error, "Contraseña requerida"}
  defp validar_password(""), do: {:error, "Contraseña no puede estar vacía"}

  defp validar_password(password) when is_binary(password) do
    cond do
      String.length(password) < 6 ->
        {:error, "Contraseña debe tener al menos 6 caracteres"}

      String.length(password) > 100 ->
        {:error, "Contraseña demasiado larga"}

      true ->
        {:ok, :valida}
    end
  end

  defp validar_password(_), do: {:error, "Contraseña inválida"}
end
