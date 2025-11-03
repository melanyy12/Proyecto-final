defmodule Hackathon.Domain.ValidadorProyecto do
  @moduledoc """
  Validaciones para la entidad Proyecto
  """

  @min_descripcion 20
  @max_descripcion 500
  @min_nombre 5
  @max_nombre 100
  @categorias_validas [:social, :ambiental, :educativo, :salud, :tecnologia, :otro]

  def nombre_valido?(nombre) when is_binary(nombre) do
    longitud = String.length(String.trim(nombre))
    longitud >= @min_nombre and longitud <= @max_nombre
  end
  def nombre_valido?(_), do: false

  def descripcion_valida?(descripcion) when is_binary(descripcion) do
    longitud = String.length(String.trim(descripcion))
    longitud >= @min_descripcion and longitud <= @max_descripcion
  end
  def descripcion_valida?(_), do: false

  def categoria_valida?(categoria) do
    categoria in @categorias_validas
  end

  def categorias_disponibles, do: @categorias_validas

  def avance_valido?(avance) when is_binary(avance) do
    String.length(String.trim(avance)) > 0
  end
  def avance_valido?(_), do: false

  # AGREGA ESTA FUNCIÓN:
  def validar_proyecto(attrs) do
    errores = []

    errores = if not nombre_valido?(attrs[:nombre]) do
      ["Nombre debe tener entre #{@min_nombre} y #{@max_nombre} caracteres" | errores]
    else
      errores
    end

    errores = if not descripcion_valida?(attrs[:descripcion]) do
      ["Descripción debe tener entre #{@min_descripcion} y #{@max_descripcion} caracteres" | errores]
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
