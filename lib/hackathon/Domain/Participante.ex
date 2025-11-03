defmodule Hackathon.Domain.Participante do
  @enforce_keys [:id, :nombre, :correo]
  defstruct [:id, :nombre, :correo, :habilidades, :password_hash, equipo_id: nil]

  def nuevo(id, nombre, correo, habilidades \\ [], password_hash \\ nil) do
    %__MODULE__{
      id: id,
      nombre: nombre,
      correo: correo,
      habilidades: habilidades,
      password_hash: password_hash
    }
  end

  def asignar_equipo(%__MODULE__{} = participante, equipo_id) do
    %{participante | equipo_id: equipo_id}
  end

  @doc """
  Hashea una contraseña usando SHA256
  """
  def hashear_password(password) when is_binary(password) do
    :crypto.hash(:sha256, password)
    |> Base.encode64()
  end

  @doc """
  Verifica si una contraseña coincide con el hash almacenado
  """
  def verificar_password(password, password_hash) do
    hashear_password(password) == password_hash
  end
end
