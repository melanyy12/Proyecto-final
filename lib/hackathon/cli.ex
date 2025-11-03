defmodule Hackathon.CLI do
  @moduledoc """
  Interfaz de línea de comandos para la Hackathon
  """

  alias Hackathon.Services.{GestionEquipos, GestionProyectos, GestionParticipantes, GestionMentores}
  alias Hackathon.Semilla

  def main(_args \\ []) do
    mostrar_banner()
    cargar_datos_iniciales()
    menu_principal()
  end

  defp mostrar_banner do
    IO.puts("\n")
    IO.puts("===============================================")
    IO.puts("                                               ")
    IO.puts("       HACKATHON CODE4FUTURE 2025             ")
    IO.puts("                                               ")
    IO.puts("    Sistema de Gestion de Hackathon           ")
    IO.puts("                                               ")
    IO.puts("===============================================")
    IO.puts("\n")
  end

  defp cargar_datos_iniciales do
    IO.puts("Cargando datos de la hackathon...")

    case Semilla.cargar_datos() do
      {:ok, _} ->
        IO.puts("Datos cargados exitosamente\n")
        :timer.sleep(1000)
      {:error, razon} ->
        IO.puts("Error al cargar datos: #{razon}\n")
    end
  end

  defp menu_principal do
    loop_menu()
  end

  defp loop_menu do
    mostrar_opciones()

    case obtener_opcion() do
      "1" ->
        ver_equipos()
        loop_menu()

      "2" ->
        ver_proyectos()
        loop_menu()

      "3" ->
        ver_proyecto_por_equipo()
        loop_menu()

      "4" ->
        ver_proyectos_por_estado()
        loop_menu()

      "5" ->
        ver_participantes()
        loop_menu()

      "6" ->
        ver_mentores()
        loop_menu()

      "7" ->
        unirse_a_equipo()
        loop_menu()

      "8" ->
        mostrar_ayuda()
        loop_menu()

      "9" ->
        recargar_datos()
        loop_menu()

      "0" ->
        salir()

      _ ->
        IO.puts("\nOpcion invalida. Intente de nuevo.\n")
        loop_menu()
    end
  end

  defp mostrar_opciones do
    IO.puts("\n")
    IO.puts("=============== MENU PRINCIPAL ================")
    IO.puts("")
    IO.puts("  1. Ver todos los equipos")
    IO.puts("  2. Ver todos los proyectos")
    IO.puts("  3. Buscar proyecto por equipo")
    IO.puts("  4. Filtrar proyectos por estado")
    IO.puts("  5. Ver participantes")
    IO.puts("  6. Ver mentores")
    IO.puts("  7. Unirse a un equipo (/join)")
    IO.puts("  8. Ayuda (/help)")
    IO.puts("  9. Recargar datos")
    IO.puts("  0. Salir")
    IO.puts("")
    IO.puts("===============================================")
  end

  defp obtener_opcion do
    IO.gets("\nSeleccione una opcion: ")
    |> String.trim()
  end

  # ========== OPCIONES DEL MENU ==========

  defp ver_equipos do
    IO.puts("\n")
    IO.puts("===============================================")
    IO.puts("           EQUIPOS REGISTRADOS                ")
    IO.puts("===============================================")
    IO.puts("")

    case GestionEquipos.listar_equipos() do
      {:ok, []} ->
        IO.puts("  No hay equipos registrados.\n")

      {:ok, equipos} ->
        equipos
        |> Enum.with_index(1)
        |> Enum.each(fn {equipo, index} ->
          IO.puts("  #{index}. #{equipo.nombre}")
          IO.puts("     Tema: #{equipo.tema}")
          IO.puts("     Categoria: #{equipo.categoria}")
          IO.puts("     Miembros: #{length(equipo.miembros)}")
          IO.puts("     ID: #{String.slice(equipo.id, 0..7)}...")
          IO.puts("")
        end)

      {:error, razon} ->
        IO.puts("  Error: #{razon}\n")
    end

    pausar()
  end

  defp ver_proyectos do
    IO.puts("\n")
    IO.puts("===============================================")
    IO.puts("          PROYECTOS DE LA HACKATHON           ")
    IO.puts("===============================================")
    IO.puts("")

    case GestionProyectos.listar_proyectos() do
      {:ok, []} ->
        IO.puts("  No hay proyectos registrados.\n")

      {:ok, proyectos} ->
        proyectos
        |> Enum.with_index(1)
        |> Enum.each(fn {proyecto, index} ->
          mostrar_proyecto_detallado(proyecto, index)
        end)

      {:error, razon} ->
        IO.puts("  Error: #{razon}\n")
    end

    pausar()
  end

  defp ver_proyecto_por_equipo do
    IO.puts("\nIngrese el nombre del equipo:")
    nombre = IO.gets("> ") |> String.trim()

    case GestionEquipos.buscar_por_nombre(nombre) do
      {:ok, equipo} ->
        IO.puts("\nEquipo encontrado: #{equipo.nombre}\n")

        case GestionProyectos.obtener_por_equipo(equipo.id) do
          {:ok, proyecto} ->
            mostrar_proyecto_detallado(proyecto, 1)

          {:error, :no_encontrado} ->
            IO.puts("Este equipo aun no tiene un proyecto registrado.\n")

          {:error, razon} ->
            IO.puts("Error: #{razon}\n")
        end

      {:error, :no_encontrado} ->
        IO.puts("\nEquipo no encontrado.\n")

      {:error, razon} ->
        IO.puts("\nError: #{razon}\n")
    end

    pausar()
  end

  defp ver_proyectos_por_estado do
    IO.puts("\nSeleccione el estado:")
    IO.puts("  1. Iniciado")
    IO.puts("  2. En Progreso")
    IO.puts("  3. Finalizado")

    opcion = IO.gets("\n> ") |> String.trim()

    estado = case opcion do
      "1" -> :iniciado
      "2" -> :en_progreso
      "3" -> :finalizado
      _ -> nil
    end

    if estado do
      case GestionProyectos.consultar_por_estado(estado) do
        {:ok, proyectos} ->
          IO.puts("\n")
          IO.puts("=== Proyectos en estado: #{estado} ===\n")

          if Enum.empty?(proyectos) do
            IO.puts("No hay proyectos en este estado.\n")
          else
            Enum.with_index(proyectos, 1)
            |> Enum.each(fn {proyecto, index} ->
              IO.puts("#{index}. #{proyecto.nombre} (#{proyecto.categoria})")
            end)
          end

        {:error, razon} ->
          IO.puts("\nError: #{razon}\n")
      end
    else
      IO.puts("\nOpcion invalida.\n")
    end

    pausar()
  end

  defp ver_participantes do
    IO.puts("\n")
    IO.puts("===============================================")
    IO.puts("        PARTICIPANTES REGISTRADOS             ")
    IO.puts("===============================================")
    IO.puts("")

    case GestionParticipantes.listar_participantes() do
      {:ok, []} ->
        IO.puts("  No hay participantes registrados.\n")

      {:ok, participantes} ->
        participantes
        |> Enum.with_index(1)
        |> Enum.each(fn {participante, index} ->
          equipo_texto = if participante.equipo_id do
            "Equipo asignado: Si"
          else
            "Sin equipo"
          end

          IO.puts("  #{index}. #{participante.nombre}")
          IO.puts("     Correo: #{participante.correo}")
          IO.puts("     Habilidades: #{Enum.join(participante.habilidades, ", ")}")
          IO.puts("     #{equipo_texto}")
          IO.puts("")
        end)

      {:error, razon} ->
        IO.puts("  Error: #{razon}\n")
    end

    pausar()
  end

  defp ver_mentores do
    IO.puts("\n")
    IO.puts("===============================================")
    IO.puts("           MENTORES REGISTRADOS               ")
    IO.puts("===============================================")
    IO.puts("")

    case GestionMentores.listar_mentores() do
      {:ok, []} ->
        IO.puts("  No hay mentores registrados.\n")

      {:ok, mentores} ->
        mentores
        |> Enum.with_index(1)
        |> Enum.each(fn {mentor, index} ->
          IO.puts("  #{index}. #{mentor.nombre}")
          IO.puts("     Especialidad: #{mentor.especialidad}")
          IO.puts("     Correo: #{mentor.correo}")
          IO.puts("     Equipos asignados: #{length(mentor.equipos_asignados)}")
          IO.puts("     Disponible: #{if mentor.disponible, do: "Si", else: "No"}")
          IO.puts("")
        end)

      {:error, razon} ->
        IO.puts("  Error: #{razon}\n")
    end

    pausar()
  end

  defp unirse_a_equipo do
    IO.puts("\n=== UNIRSE A UN EQUIPO ===\n")

    IO.puts("Ingrese su correo electronico:")
    correo = IO.gets("> ") |> String.trim()

    case GestionParticipantes.buscar_por_correo(correo) do
      {:ok, participante} ->
        IO.puts("\nBienvenido, #{participante.nombre}!\n")

        if participante.equipo_id do
          IO.puts("Ya estas en un equipo.\n")
        else
          case GestionEquipos.listar_equipos() do
            {:ok, equipos} ->
              IO.puts("Equipos disponibles:\n")
              equipos
              |> Enum.with_index(1)
              |> Enum.each(fn {equipo, index} ->
                IO.puts("  #{index}. #{equipo.nombre} - #{equipo.tema}")
                IO.puts("     Miembros: #{length(equipo.miembros)}/#{equipo.max_miembros}")
              end)

              IO.puts("\nIngrese el numero del equipo:")

              case IO.gets("> ") |> String.trim() |> Integer.parse() do
                {opcion, _} ->
                  if equipo = Enum.at(equipos, opcion - 1) do
                    case GestionParticipantes.unirse_a_equipo(participante.id, equipo.id) do
                      {:ok, _} ->
                        IO.puts("\nExito! Te uniste al equipo #{equipo.nombre}\n")
                      {:error, razon} ->
                        IO.puts("\nError: #{razon}\n")
                    end
                  else
                    IO.puts("\nOpcion invalida.\n")
                  end
                _ ->
                  IO.puts("\nEntrada invalida.\n")
              end

            {:error, razon} ->
              IO.puts("Error al listar equipos: #{razon}\n")
          end
        end

      {:error, :no_encontrado} ->
        IO.puts("\nParticipante no encontrado. Verifique su correo.\n")

      {:error, razon} ->
        IO.puts("\nError: #{razon}\n")
    end

    pausar()
  end

  defp mostrar_ayuda do
    IO.puts("\n")
    IO.puts("===============================================")
    IO.puts("              COMANDOS DISPONIBLES            ")
    IO.puts("===============================================")
    IO.puts("")
    IO.puts("  /teams         - Listar todos los equipos")
    IO.puts("  /project       - Buscar proyecto por equipo")
    IO.puts("  /participants  - Ver participantes registrados")
    IO.puts("  /mentors       - Ver mentores registrados")
    IO.puts("  /join          - Unirse a un equipo")
    IO.puts("  /help          - Mostrar esta ayuda")
    IO.puts("")
    IO.puts("===============================================")
    IO.puts("")

    pausar()
  end

  defp recargar_datos do
    IO.puts("\nRecargando datos...\n")

    case Semilla.cargar_datos() do
      {:ok, _} ->
        IO.puts("Datos recargados exitosamente\n")
      {:error, razon} ->
        IO.puts("Error: #{razon}\n")
    end

    pausar()
  end

  defp salir do
    IO.puts("\n")
    IO.puts("===============================================")
    IO.puts("                                               ")
    IO.puts("      Gracias por usar Code4Future!           ")
    IO.puts("                                               ")
    IO.puts("         Desarrollado en Elixir                ")
    IO.puts("                                               ")
    IO.puts("===============================================")
    IO.puts("\n")
    System.halt(0)
  end

  # ========== FUNCIONES AUXILIARES ==========

  defp mostrar_proyecto_detallado(proyecto, index) do
    IO.puts("  #{index}. [#{estado_texto(proyecto.estado)}] #{proyecto.nombre}")
    IO.puts("     Descripcion: #{proyecto.descripcion}")
    IO.puts("     Categoria: #{proyecto.categoria}")
    IO.puts("     Estado: #{proyecto.estado}")
    IO.puts("     Avances: #{length(proyecto.avances)}")

    if length(proyecto.avances) > 0 do
      IO.puts("     ")
      Enum.take(proyecto.avances, 3)
      |> Enum.each(fn avance ->
        IO.puts("       - #{avance.contenido}")
      end)
    end

    IO.puts("     Retroalimentacion: #{length(proyecto.retroalimentacion)}")

    if length(proyecto.retroalimentacion) > 0 do
      IO.puts("     ")
      Enum.take(proyecto.retroalimentacion, 2)
      |> Enum.each(fn retro ->
        IO.puts("       - [#{retro.mentor_id}]: #{retro.comentario}")
      end)
    end

    IO.puts("")
  end

  defp estado_texto(estado) do
    case estado do
      :iniciado -> "INICIADO"
      :en_progreso -> "EN PROGRESO"
      :finalizado -> "FINALIZADO"
      :presentado -> "PRESENTADO"
      _ -> "DESCONOCIDO"
    end
  end

  defp pausar do
    IO.gets("\nPresione ENTER para continuar...")
    :ok
  end
end
