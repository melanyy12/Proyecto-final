# lib/hackathon/adapters/cli/comandos.ex
defmodule Hackathon.Adapters.CLI.Comandos do
  alias Hackathon.Services.GestionEquipos

  def listar_equipos do
    case GestionEquipos.listar_equipos() do
      {:ok, equipos} when equipos == [] ->
        IO.puts("\n No hay equipos registrados aún.\n")

      {:ok, equipos} ->
        IO.puts("\n === EQUIPOS REGISTRADOS ===\n")
        Enum.each(equipos, fn equipo ->
          IO.puts("  #{equipo.nombre}")
          IO.puts("     Tema: #{equipo.tema}")
          IO.puts("     Miembros: #{length(equipo.miembros)}")
          IO.puts("")
        end)

      {:error, razon} ->
        IO.puts(" Error al listar equipos: #{razon}")
    end
  end

  def mostrar_proyecto(nombre_equipo) do
    # Implementación para mostrar proyecto
    IO.puts("\n Información del proyecto del equipo: #{nombre_equipo}\n")
  end

  def unirse_equipo(equipo) do
    IO.puts("\n Solicitud para unirse al equipo '#{equipo}' enviada.\n")
  end

  def ingresar_chat(equipo) do
    IO.puts("\n Ingresando al chat del equipo '#{equipo}'...\n")
    IO.puts("Escribe tus mensajes (escribe 'salir' para salir):\n")
  end

  def mostrar_ayuda do
    IO.puts("""

     === COMANDOS DISPONIBLES ===

    /teams                    → Listar todos los equipos registrados
    /project <nombre_equipo>  → Mostrar información del proyecto de un equipo
    /join <equipo>            → Unirse a un equipo
    /chat <equipo>            → Ingresar al canal de chat de un equipo
    /help                     → Mostrar esta ayuda

    """)
  end
end
