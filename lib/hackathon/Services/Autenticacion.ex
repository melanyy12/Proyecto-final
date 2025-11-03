defmodule Hackathon.Services.Autenticacion do
  @moduledoc """
  Servicio de autenticación para participantes y mentores usando contraseñas
  """

  alias Hackathon.Services.{GestionParticipantes, GestionMentores}
  alias Hackathon.Domain.{Participante, Mentor}

  @doc """
  Inicializa la tabla ETS para sesiones
  """
  def inicializar_sesiones do
    case :ets.whereis(:sesiones) do
      :undefined ->
        :ets.new(:sesiones, [:set, :public, :named_table])
        :ok
      _ ->
        :ok
    end
  end

  @doc """
  Autentica un participante usando su correo y contraseña
  """
  def autenticar_participante(correo, password) when is_binary(correo) and is_binary(password) do
    inicializar_sesiones()

    case GestionParticipantes.buscar_por_correo(correo) do
      {:ok, participante} ->
        if participante.password_hash && Participante.verificar_password(password, participante.password_hash) do
          token = generar_token()
          :ets.insert(:sesiones, {token, {:participante, participante.id, DateTime.utc_now()}})
          {:ok, %{token: token, usuario: participante, rol: :participante}}
        else
          {:error, "Contraseña incorrecta"}
        end

      {:error, :no_encontrado} ->
        {:error, "Participante no encontrado"}

      error ->
        error
    end
  end

  @doc """
  Autentica un mentor usando su correo y contraseña
  """
  def autenticar_mentor(correo, password) when is_binary(correo) and is_binary(password) do
    inicializar_sesiones()

    case buscar_mentor_por_correo(correo) do
      {:ok, mentor} ->
        if mentor.password_hash && Mentor.verificar_password(password, mentor.password_hash) do
          token = generar_token()
          :ets.insert(:sesiones, {token, {:mentor, mentor.id, DateTime.utc_now()}})
          {:ok, %{token: token, usuario: mentor, rol: :mentor}}
        else
          {:error, "Contraseña incorrecta"}
        end

      {:error, :no_encontrado} ->
        {:error, "Mentor no encontrado"}

      error ->
        error
    end
  end

  @doc """
  Verifica si un token es válido y obtiene el usuario asociado
  """
  def verificar_sesion(token) do
    inicializar_sesiones()

    case :ets.lookup(:sesiones, token) do
      [{^token, {rol, usuario_id, fecha_login}}] ->
        if sesion_valida?(fecha_login) do
          obtener_usuario(rol, usuario_id)
        else
          cerrar_sesion(token)
          {:error, "Sesión expirada"}
        end

      [] ->
        {:error, "Token inválido"}
    end
  end

  @doc """
  Cierra una sesión
  """
  def cerrar_sesion(token) do
    inicializar_sesiones()
    :ets.delete(:sesiones, token)
    :ok
  end

  @doc """
  Lista todas las sesiones activas (útil para administración)
  """
  def listar_sesiones_activas do
    inicializar_sesiones()

    :ets.tab2list(:sesiones)
    |> Enum.filter(fn {_token, {_rol, _id, fecha}} ->
      sesion_valida?(fecha)
    end)
  end

  @doc """
  Limpia sesiones expiradas
  """
  def limpiar_sesiones_expiradas do
    inicializar_sesiones()

    :ets.tab2list(:sesiones)
    |> Enum.each(fn {token, {_rol, _id, fecha}} ->
      unless sesion_valida?(fecha) do
        :ets.delete(:sesiones, token)
      end
    end)

    :ok
  end

  @doc """
  Obtiene la sesión actual desde el token
  """
  def sesion_actual(token) do
    verificar_sesion(token)
  end

  @doc """
  Verifica si un usuario tiene permisos de mentor
  """
  def es_mentor?(token) do
    case verificar_sesion(token) do
      {:ok, %{rol: :mentor}} -> true
      _ -> false
    end
  end

  @doc """
  Verifica si un usuario tiene permisos de participante
  """
  def es_participante?(token) do
    case verificar_sesion(token) do
      {:ok, %{rol: :participante}} -> true
      _ -> false
    end
  end

  # Funciones privadas

  defp generar_token do
    :crypto.strong_rand_bytes(32)
    |> Base.url_encode64()
    |> binary_part(0, 32)
  end

  defp sesion_valida?(fecha_login) do
    # Sesión válida por 24 horas
    DateTime.diff(DateTime.utc_now(), fecha_login, :hour) < 24
  end

  defp obtener_usuario(:participante, usuario_id) do
    case GestionParticipantes.obtener_participante(usuario_id) do
      {:ok, participante} ->
        {:ok, %{usuario: participante, rol: :participante}}

      error ->
        error
    end
  end

  defp obtener_usuario(:mentor, usuario_id) do
    case GestionMentores.obtener_mentor(usuario_id) do
      {:ok, mentor} ->
        {:ok, %{usuario: mentor, rol: :mentor}}

      error ->
        error
    end
  end

  defp buscar_mentor_por_correo(correo) do
    case GestionMentores.listar_mentores() do
      {:ok, mentores} ->
        case Enum.find(mentores, fn m -> String.downcase(m.correo) == String.downcase(correo) end) do
          nil -> {:error, :no_encontrado}
          mentor -> {:ok, mentor}
        end

      error ->
        error
    end
  end
end
