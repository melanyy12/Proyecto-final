defmodule Hackathon.Services.SistemaChat do
  @moduledoc """
  Sistema de chat distribuido con procesos concurrentes por canal
  """
  use GenServer

  alias Hackathon.Domain.Mensaje
  alias Hackathon.Adapters.Persistencia.RepositorioMensajes

  # Client API

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts ++ [name: __MODULE__])
  end

  @doc """
  Envía un mensaje a un canal específico
  """
  def enviar_mensaje(emisor_id, contenido, canal) do
    GenServer.call(__MODULE__, {:enviar_mensaje, emisor_id, contenido, canal})
  end

  @doc """
  Obtiene el historial de mensajes de un canal
  """
  def obtener_historial(canal) do
    GenServer.call(__MODULE__, {:historial, canal})
  end

  @doc """
  Suscribe un proceso para recibir notificaciones de un canal
  """
  def suscribirse_canal(canal, pid \\ self()) do
    GenServer.cast(__MODULE__, {:suscribir, canal, pid})
  end

  @doc """
  Desuscribe un proceso de un canal
  """
  def desuscribirse_canal(canal, pid \\ self()) do
    GenServer.cast(__MODULE__, {:desuscribir, canal, pid})
  end

  @doc """
  Obtiene estadísticas del sistema de chat
  """
  def obtener_estadisticas do
    GenServer.call(__MODULE__, :estadisticas)
  end

  # Server Callbacks

  @impl true
  def init(:ok) do
    # Inicializar tabla ETS para suscriptores
    :ets.new(:chat_suscriptores, [:bag, :public, :named_table])

    estado = %{
      mensajes_enviados: 0,
      canales_activos: MapSet.new(),
      inicio: DateTime.utc_now()
    }

    {:ok, estado}
  end

  @impl true
  def handle_call({:enviar_mensaje, emisor_id, contenido, canal}, _from, estado) do
    # Crear mensaje
    mensaje = Mensaje.nuevo(generar_id(), emisor_id, contenido, canal)

    # Guardar en persistencia de forma asíncrona
    Task.start(fn ->
      RepositorioMensajes.guardar(mensaje)
    end)

    # Notificar a suscriptores usando procesos concurrentes
    Task.start(fn ->
      notificar_suscriptores_async(canal, mensaje)
    end)

    # Actualizar estadísticas
    nuevo_estado = %{
      estado |
      mensajes_enviados: estado.mensajes_enviados + 1,
      canales_activos: MapSet.put(estado.canales_activos, canal)
    }

    {:reply, {:ok, mensaje}, nuevo_estado}
  end

  @impl true
  def handle_call({:historial, canal}, _from, estado) do
    # Obtener historial de forma asíncrona
    task = Task.async(fn ->
      case RepositorioMensajes.obtener_por_canal(canal) do
        {:ok, mensajes} -> mensajes
        _ -> []
      end
    end)

    mensajes = Task.await(task, 5000)
    {:reply, {:ok, mensajes}, estado}
  end

  @impl true
  def handle_call(:estadisticas, _from, estado) do
    canales_count = MapSet.size(estado.canales_activos)
    suscriptores_count = :ets.info(:chat_suscriptores, :size)
    tiempo_activo = DateTime.diff(DateTime.utc_now(), estado.inicio, :second)

    stats = %{
      mensajes_enviados: estado.mensajes_enviados,
      canales_activos: canales_count,
      suscriptores_totales: suscriptores_count,
      tiempo_activo_segundos: tiempo_activo,
      inicio: estado.inicio
    }

    {:reply, {:ok, stats}, estado}
  end

  @impl true
  def handle_cast({:suscribir, canal, pid}, estado) do
    :ets.insert(:chat_suscriptores, {canal, pid})

    # Monitorear el proceso suscriptor
    Process.monitor(pid)

    {:noreply, estado}
  end

  @impl true
  def handle_cast({:desuscribir, canal, pid}, estado) do
    :ets.match_delete(:chat_suscriptores, {canal, pid})
    {:noreply, estado}
  end

  @impl true
  def handle_info({:DOWN, _ref, :process, pid, _reason}, estado) do
    # Limpiar suscripciones del proceso caído
    :ets.match_delete(:chat_suscriptores, {:_, pid})
    {:noreply, estado}
  end

  @impl true
  def handle_info(_msg, estado) do
    {:noreply, estado}
  end

  # Funciones privadas

  defp notificar_suscriptores_async(canal, mensaje) do
    # Obtener todos los suscriptores del canal
    suscriptores = :ets.lookup(:chat_suscriptores, canal)

    # Notificar a cada suscriptor en paralelo
    suscriptores
    |> Enum.map(fn {_canal, pid} ->
      Task.async(fn ->
        if Process.alive?(pid) do
          send(pid, {:nuevo_mensaje, mensaje})
        end
      end)
    end)
    |> Enum.each(&Task.await(&1, 1000))
  end

  defp generar_id do
    :crypto.strong_rand_bytes(16) |> Base.encode16(case: :lower)
  end
end


# ============================================
# CANAL DE CHAT INDIVIDUAL (Proceso por canal)
# ============================================

defmodule Hackathon.Services.CanalChat do
  @moduledoc """
  Proceso GenServer que representa un canal de chat individual.
  Cada equipo puede tener su propio proceso de canal.
  """
  use GenServer

  def start_link(canal_id) do
    GenServer.start_link(__MODULE__, canal_id, name: via_tuple(canal_id))
  end

  defp via_tuple(canal_id) do
    {:via, Registry, {Hackathon.CanalRegistry, canal_id}}
  end

  @impl true
  def init(canal_id) do
    {:ok, %{canal_id: canal_id, suscriptores: [], mensajes_cache: []}}
  end

  @impl true
  def handle_call({:enviar, mensaje}, _from, estado) do
    # Guardar en cache (últimos 50 mensajes)
    nuevos_mensajes = [mensaje | estado.mensajes_cache] |> Enum.take(50)

    # Notificar suscriptores
    Enum.each(estado.suscriptores, fn pid ->
      send(pid, {:mensaje_canal, mensaje})
    end)

    {:reply, :ok, %{estado | mensajes_cache: nuevos_mensajes}}
  end

  @impl true
  def handle_cast({:suscribir, pid}, estado) do
    Process.monitor(pid)
    {:noreply, %{estado | suscriptores: [pid | estado.suscriptores]}}
  end

  @impl true
  def handle_info({:DOWN, _ref, :process, pid, _reason}, estado) do
    nuevos_suscriptores = List.delete(estado.suscriptores, pid)
    {:noreply, %{estado | suscriptores: nuevos_suscriptores}}
  end
end
