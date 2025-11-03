defmodule Hackathon.Domain.ValidadorEquipo do
  @moduledoc """
  Validaciones para la entidad Equipo
  """

  @min_nombre 3
  @max_nombre 50
  @categorias_validas [:social, :ambiental, :educativo, :salud, :tecnologia, :otro]

  def nombre_valido?(nombre) when is_binary(nombre) do
    longitud = String.length(String.trim(nombre))
    longitud >= @min_nombre and longitud <= @max_nombre
  end
  def nombre_valido?(_), do: false

  def tema_valido?(tema) when is_binary(tema) do
    String.length(String.trim(tema)) > 0
  end
  def tema_valido?(_), do: false

  def categoria_valida?(categoria) do
    categoria in @categorias_validas
  end

  def categorias_disponibles, do: @categorias_validas

  # ESTA ES LA FUNCIÓN QUE FALTA:
  def validar_equipo(attrs) do
    errores = []

    errores = if not nombre_valido?(attrs[:nombre]) do
      ["Nombre debe tener entre #{@min_nombre} y #{@max_nombre} caracteres" | errores]
    else
      errores
    end

    errores = if not tema_valido?(attrs[:tema]) do
      ["Tema no puede estar vacío" | errores]
    else
      errores
    end

    errores = if not categoria_valida?(attrs[:categoria]) do
      ["Categoría inválida. Opciones: #{inspect(@categorias_validas)}" | errores]
    else
      errores
    end

    case errores do
      [] -> {:ok, :valido}
      _ -> {:error, Enum.reverse(errores)}
    end
  end
end
