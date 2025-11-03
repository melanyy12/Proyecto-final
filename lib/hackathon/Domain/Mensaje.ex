
defmodule Hackathon.Domain.Mensaje do
  @enforce_keys [:id, :emisor_id, :contenido, :canal]
  defstruct [:id, :emisor_id, :contenido, :canal, :tipo, fecha: nil]

  def nuevo(id, emisor_id, contenido, canal, tipo \\ :normal) do
    %__MODULE__{
      id: id,
      emisor_id: emisor_id,
      contenido: contenido,
      canal: canal,
      tipo: tipo,
      fecha: DateTime.utc_now()
    }
  end
end
