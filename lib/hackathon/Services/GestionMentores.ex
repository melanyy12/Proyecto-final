defmodule Hackathon.Services.GestionMentores do
  @moduledoc """
  Servicio para gestionar mentores de la hackathon
  """

  alias Hackathon.Domain.Mentor
  alias Hackathon.Adapters.Persistencia.RepositorioMentores

  @doc """
  Registra un nuevo mentor con contraseña
  """
  def registrar_mentor(attrs) do
    with {:ok, _} <- validar_password(attrs[:password]),
         password_hash <- Mentor.hashear_password(attrs[:password]),
         mentor <- Mentor.nuevo(
           generar_id(),
           attrs.nombre,
           attrs.especialidad,
           attrs.correo,
           password_hash
         ),
         :ok <- RepositorioMentores.guardar(mentor) do
      {:ok, mentor}
    else
      {:error, razon} -> {:error, razon}
    end
  end

  @doc """
  Asigna un mentor a un equipo
  """
  def asignar_a_equipo(mentor_id, equipo_id) do
    with {:ok, mentor} <- RepositorioMentores.obtener(mentor_id),
         {:ok, mentor_actualizado} <- Mentor.asignar_equipo(mentor, equipo_id),
         :ok <- RepositorioMentores.actualizar(mentor_actualizado) do
      {:ok, mentor_actualizado}
    else
      {:error, razon} -> {:error, razon}
    end
  end

  @doc """
  Lista todos los mentores
  """
  def listar_mentores do
    RepositorioMentores.listar_todos()
  end

  @doc """
  Obtiene un mentor por su ID
  """
  def obtener_mentor(mentor_id) do
    RepositorioMentores.obtener(mentor_id)
  end

  @doc """
  Lista mentores disponibles (con capacidad)
  """
  def listar_disponibles do
    case listar_mentores() do
      {:ok, mentores} ->
        disponibles = Enum.filter(mentores, fn m -> Mentor.tiene_capacidad?(m) end)
        {:ok, disponibles}

      error ->
        error
    end
  end

  @doc """
  Cambia la contraseña de un mentor
  """
  def cambiar_password(mentor_id, password_actual, password_nueva) do
    with {:ok, mentor} <- RepositorioMentores.obtener(mentor_id),
         true <- Mentor.verificar_password(password_actual, mentor.password_hash),
         {:ok, _} <- validar_password(password_nueva),
         password_hash <- Mentor.hashear_password(password_nueva),
         mentor_actualizado <- %{mentor | password_hash: password_hash},
         :ok <- RepositorioMentores.actualizar(mentor_actualizado) do
      {:ok, mentor_actualizado}
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
