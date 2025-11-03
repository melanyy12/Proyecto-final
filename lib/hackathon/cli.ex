defmodule Hackathon.CLI do
  @moduledoc """
  Interfaz de línea de comandos para la Hackathon
  """

  alias Hackathon.Services.{GestionEquipos, GestionProyectos}
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
        recargar_datos()
        loop_menu()

      "6" ->
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
    IO.puts("  5. Recargar datos")
    IO.puts("  6. Salir")
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
