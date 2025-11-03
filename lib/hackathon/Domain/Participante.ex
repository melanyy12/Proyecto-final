
defmodule Hackathon.Domain.Participante do
  @enforce_keys [:id, :nombre, :correo]
  defstruct [:id, :nombre, :correo, :habilidades, equipo_id: nil]

  def nuevo(id, nombre, correo, habilidades \\ []) do
    %__MODULE__{
      id: id,
      nombre: nombre,
      correo: correo,
      habilidades: habilidades
    }
  end

  def asignar_equipo(%__MODULE__{} = participante, equipo_id) do
    %{participante | equipo_id: equipo_id}
  end
end
