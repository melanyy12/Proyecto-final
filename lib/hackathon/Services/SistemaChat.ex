
defmodule Hackathon.Services.SistemaChat do
  use GenServer
  alias Hackathon.Domain.Mensaje
  alias Hackathon.Adapters.Persistencia.RepositorioMensajes

  # Client API
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts ++ [name: __MODULE__])
  end

  def enviar_mensaje(emisor_id, contenido, canal) do
    GenServer.call(__MODULE__, {:enviar_mensaje, emisor_id, contenido, canal})
  end

  def obtener_historial(canal) do
    GenServer.call(__MODULE__, {:historial, canal})
  end

  def suscribirse_canal(canal, pid) do
    GenServer.cast(__MODULE__, {:suscribir, canal, pid})
  end

  # Server Callbacks
  @impl true
  def init(:ok) do
    {:ok, %{suscriptores: %{}}}
  end

  @impl true
  def handle_call({:enviar_mensaje, emisor_id, contenido, canal}, _from, state) do
    mensaje = Mensaje.nuevo(generar_id(), emisor_id, contenido, canal)
    RepositorioMensajes.guardar(mensaje)

    # Notificar a suscriptores
    notificar_suscriptores(state.suscriptores, canal, mensaje)

    {:reply, {:ok, mensaje}, state}
  end

  @impl true
  def handle_call({:historial, canal}, _from, state) do
    mensajes = RepositorioMensajes.obtener_por_canal(canal)
    {:reply, {:ok, mensajes}, state}
  end

  @impl true
  def handle_cast({:suscribir, canal, pid}, state) do
    suscriptores = Map.update(state.suscriptores, canal, [pid], fn pids -> [pid | pids] end)
    {:noreply, %{state | suscriptores: suscriptores}}
  end

  defp notificar_suscriptores(suscriptores, canal, mensaje) do
    case Map.get(suscriptores, canal) do
      nil -> :ok
      pids -> Enum.each(pids, fn pid -> send(pid, {:nuevo_mensaje, mensaje}) end)
    end
  end

  defp generar_id, do: UUID.uuid4()
end
