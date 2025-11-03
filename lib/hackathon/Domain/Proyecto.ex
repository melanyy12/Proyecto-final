
defmodule Hackathon.Domain.Proyecto do
  @enforce_keys [:id, :nombre, :equipo_id]
  defstruct [
    :id,
    :nombre,
    :descripcion,
    :categoria,
    :equipo_id,
    avances: [],
    retroalimentacion: [],
    estado: :iniciado,
    fecha_creacion: nil,
    fecha_actualizacion: nil
  ]

  def nuevo(id, nombre, descripcion, categoria, equipo_id) do
    %__MODULE__{
      id: id,
      nombre: nombre,
      descripcion: descripcion,
      categoria: categoria,
      equipo_id: equipo_id,
      fecha_creacion: DateTime.utc_now()
    }
  end

  def agregar_avance(%__MODULE__{} = proyecto, avance) do
    nuevo_avance = %{
      contenido: avance,
      fecha: DateTime.utc_now()
    }
    %{proyecto | avances: [nuevo_avance | proyecto.avances]}
  end

  def agregar_retroalimentacion(%__MODULE__{} = proyecto, mentor_id, comentario) do
    feedback = %{
      mentor_id: mentor_id,
      comentario: comentario,
      fecha: DateTime.utc_now()
    }
    %{proyecto | retroalimentacion: [feedback | proyecto.retroalimentacion]}
  end

  def cambiar_estado(%__MODULE__{} = proyecto, nuevo_estado)
    when nuevo_estado in [:iniciado, :en_progreso, :finalizado] do
    %{proyecto | estado: nuevo_estado}
  end
end
