
defmodule Hackathon.Adapters.CLI.CLIMain do
  alias Hackathon.Adapters.CLI.Comandos

  def run(argv) do
    case argv do
      ["/teams"] ->
        Comandos.listar_equipos()

      ["/project", nombre_equipo] ->
        Comandos.mostrar_proyecto(nombre_equipo)

      ["/join", equipo] ->
        Comandos.unirse_equipo(equipo)

      ["/chat", equipo] ->
        Comandos.ingresar_chat(equipo)

      ["/help"] ->
        Comandos.mostrar_ayuda()

      _ ->
        IO.puts("Comando no reconocido. Usa /help para ver comandos disponibles.")
    end
  end
end
