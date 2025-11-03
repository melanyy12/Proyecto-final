defmodule Hackathon.Domain.ValidadorParticipante do
  @moduledoc """
  Validaciones para la entidad Participante
  """

  @min_nombre 3
  @max_nombre 100
  @regex_email ~r/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/

  @doc """
  Valida que el nombre sea válido
  """
  def nombre_valido?(nombre) when is_binary(nombre) do
    longitud = String.length(String.trim(nombre))
    longitud >= @min_nombre and longitud <= @max_nombre
  end
  def nombre_valido?(_), do: false

  @doc """
  Valida que el correo sea válido
  """
  def correo_valido?(correo) when is_binary(correo) do
    String.match?(correo, @regex_email)
  end
  def correo_valido?(_), do: false

  @doc """
  Valida que las habilidades sean una lista válida
  """
  def habilidades_validas?(habilidades) when is_list(habilidades) do
    Enum.all?(habilidades, &is_binary/1)
  end
  def habilidades_validas?(_), do: false

  @doc """
  Valida todos los atributos de un participante
  """
  def validar_participante(attrs) do
    errores = []

    errores = if not nombre_valido?(attrs[:nombre]) do
      ["Nombre debe tener entre #{@min_nombre} y #{@max_nombre} caracteres" | errores]
    else
      errores
    end

    errores = if not correo_valido?(attrs[:correo]) do
      ["Correo electrónico inválido" | errores]
    else
      errores
    end

    habilidades = attrs[:habilidades] || []
    errores = if not habilidades_validas?(habilidades) do
      ["Habilidades debe ser una lista de textos" | errores]
    else
      errores
    end

    case errores do
      [] -> {:ok, :valido}
      _ -> {:error, Enum.reverse(errores)}
    end
  end
end
