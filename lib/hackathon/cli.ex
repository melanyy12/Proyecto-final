defmodule Hackathon.CLI do
  @moduledoc """
  Interfaz de línea de comandos para la Hackathon
  """

  alias Hackathon.Services.{GestionEquipos, GestionProyectos, GestionParticipantes, GestionMentores, SistemaChat}
  alias Hackathon.Semilla

  @password_acceso "ingreso123"

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
  {:ok, _} = Semilla.cargar_datos()  # <-- CAMBIO AQUÍ (quitar _iniciales)
  IO.puts("Datos cargados exitosamente\n")
  :timer.sleep(1000)
end

  defp menu_principal do
    loop_menu()
  end

  defp loop_menu do
  mostrar_opciones()

  case obtener_opcion() do
    "1" -> ver_equipos() |> then(fn _ -> loop_menu() end)
    "2" -> ver_proyectos() |> then(fn _ -> loop_menu() end)
    "3" -> ver_proyecto_por_equipo() |> then(fn _ -> loop_menu() end)
    "4" -> ver_proyectos_por_estado() |> then(fn _ -> loop_menu() end)
    "5" -> ver_participantes_protegido() |> then(fn _ -> loop_menu() end)
    "6" -> ver_mentores_protegido() |> then(fn _ -> loop_menu() end)
    "7" -> registrar_participante() |> then(fn _ -> loop_menu() end)
    "8" -> unirse_equipo() |> then(fn _ -> loop_menu() end)
    "9" -> crear_equipo() |> then(fn _ -> loop_menu() end)
    "10" -> crear_proyecto() |> then(fn _ -> loop_menu() end)
    "11" -> registrar_mentor() |> then(fn _ -> loop_menu() end)
    "12" -> agregar_avance() |> then(fn _ -> loop_menu() end)
    "13" -> ver_chat_equipo() |> then(fn _ -> loop_menu() end)
    "14" -> enviar_mensaje_chat() |> then(fn _ -> loop_menu() end)
    "15" -> asignar_mentor_equipo() |> then(fn _ -> loop_menu() end)
    "16" -> cambiar_estado_proyecto() |> then(fn _ -> loop_menu() end)
    "17" -> eliminar_participante() |> then(fn _ -> loop_menu() end)
    "18" -> eliminar_mentor() |> then(fn _ -> loop_menu() end)
    "19" -> eliminar_equipo() |> then(fn _ -> loop_menu() end)
    "20" -> eliminar_proyecto() |> then(fn _ -> loop_menu() end)
    "21" -> mostrar_ayuda() |> then(fn _ -> loop_menu() end)
    "22" -> recargar_datos() |> then(fn _ -> loop_menu() end)
    "0" -> salir()
    _ -> IO.puts("\nX Opcion invalida. Intente de nuevo.\n") |> then(fn _ -> loop_menu() end)
  end
end

  defp mostrar_opciones do
  IO.puts("\n")
  IO.puts("=============== MENU PRINCIPAL ================")
  IO.puts("")
  IO.puts("  CONSULTAS:")
  IO.puts("    1. Ver todos los equipos")
  IO.puts("    2. Ver todos los proyectos")
  IO.puts("    3. Buscar proyecto por equipo")
  IO.puts("    4. Filtrar proyectos por estado")
  IO.puts("    5. Ver participantes (requiere acceso)")
  IO.puts("    6. Ver mentores (requiere acceso)")
  IO.puts("")
  IO.puts("  REGISTROS:")
  IO.puts("    7. Registrar nuevo participante")
  IO.puts("    8. Unirse a un equipo")
  IO.puts("    9. Crear nuevo equipo")
  IO.puts("   10. Crear nuevo proyecto")
  IO.puts("   11. Registrar nuevo mentor")
  IO.puts("")
  IO.puts("  COLABORACION:")
  IO.puts("   12. Agregar avance a proyecto")
  IO.puts("   13. Ver chat de equipo")
  IO.puts("   14. Enviar mensaje a equipo")
  IO.puts("   15. Asignar mentor a equipo")
  IO.puts("   16. Cambiar estado de proyecto")
  IO.puts("")
  IO.puts("  ELIMINACION:")
  IO.puts("   17. Eliminar participante (requiere acceso)")
  IO.puts("   18. Eliminar mentor (requiere acceso)")
  IO.puts("   19. Eliminar equipo")
  IO.puts("   20. Eliminar proyecto")
  IO.puts("")
  IO.puts("  SISTEMA:")
  IO.puts("   21. Ayuda (/help)")
  IO.puts("   22. Recargar datos")
  IO.puts("    0. Salir")
  IO.puts("")
  IO.puts("===============================================")
end

  defp obtener_opcion do
    IO.gets("\nSeleccione una opcion: ")
    |> String.trim()
  end

  # ========== FUNCIONES DE SEGURIDAD ==========

  defp verificar_acceso_admin do
    IO.puts("\n=== ACCESO RESTRINGIDO ===")
    IO.puts("Ingrese la contraseña de acceso:")
    password = IO.gets("> ") |> String.trim()

    if password == @password_acceso do
      {:ok, :autorizado}
    else
      IO.puts("\nX Contraseña incorrecta\n")
      {:error, :no_autorizado}
    end
  end

  defp ver_participantes_protegido do
    case verificar_acceso_admin() do
      {:ok, :autorizado} -> ver_participantes()
      {:error, :no_autorizado} -> pausar()
    end
  end

  defp ver_mentores_protegido do
    case verificar_acceso_admin() do
      {:ok, :autorizado} -> ver_mentores()
      {:error, :no_autorizado} -> pausar()
    end
  end

  # ========== CONSULTAS ==========

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
          IO.puts("     Miembros: #{length(equipo.miembros)}/#{equipo.max_miembros}")
          IO.puts("     Estado: #{if equipo.activo, do: "Activo", else: "Inactivo"}")
          IO.puts("")
        end)

      _ ->
        IO.puts("  Error al listar equipos\n")
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

      _ ->
        IO.puts("  Error al listar proyectos\n")
    end

    pausar()
  end

  defp ver_proyecto_por_equipo do
    IO.puts("\n=== BUSCAR PROYECTO POR EQUIPO ===\n")
    IO.puts("Ingrese el nombre del equipo:")
    nombre = IO.gets("> ") |> String.trim()

    case GestionEquipos.buscar_por_nombre(nombre) do
      {:ok, equipo} ->
        IO.puts("\nEquipo encontrado: #{equipo.nombre}\n")

        case GestionProyectos.obtener_por_equipo(equipo.id) do
          {:ok, proyecto} ->
            mostrar_proyecto_detallado(proyecto, 1)

          {:error, :no_encontrado} ->
            IO.puts("Este equipo aun no tiene un proyecto registrado.\n")

          _ ->
            IO.puts("Error al buscar proyecto\n")
        end

      {:error, :no_encontrado} ->
        IO.puts("\nEquipo '#{nombre}' no encontrado.\n")

      _ ->
        IO.puts("\nError al buscar equipo\n")
    end

    pausar()
  end

  defp ver_proyectos_por_estado do
    IO.puts("\n=== FILTRAR PROYECTOS POR ESTADO ===\n")
    IO.puts("Seleccione el estado:")
    IO.puts("  1. Iniciado")
    IO.puts("  2. En Progreso")
    IO.puts("  3. Finalizado")
    IO.puts("  4. Presentado")

    opcion = IO.gets("\n> ") |> String.trim()

    estado = case opcion do
      "1" -> :iniciado
      "2" -> :en_progreso
      "3" -> :finalizado
      "4" -> :presentado
      _ -> nil
    end

    if estado do
      case GestionProyectos.consultar_por_estado(estado) do
        {:ok, proyectos} ->
          IO.puts("\n=== Proyectos en estado: #{estado} ===\n")

          if Enum.empty?(proyectos) do
            IO.puts("No hay proyectos en este estado.\n")
          else
            Enum.with_index(proyectos, 1)
            |> Enum.each(fn {proyecto, index} ->
              IO.puts("#{index}. #{proyecto.nombre}")
              IO.puts("   Categoria: #{proyecto.categoria}")
              IO.puts("   Avances: #{length(proyecto.avances)}")
              IO.puts("")
            end)
          end

        _ ->
          IO.puts("\nError al consultar proyectos\n")
      end
    else
      IO.puts("\nOpcion invalida.\n")
    end

    pausar()
  end

  defp ver_participantes do
    IO.puts("\n")
    IO.puts("===============================================")
    IO.puts("         PARTICIPANTES REGISTRADOS            ")
    IO.puts("===============================================")
    IO.puts("")

    case GestionParticipantes.listar_participantes() do
      {:ok, []} ->
        IO.puts("  No hay participantes registrados.\n")

      {:ok, participantes} ->
        participantes
        |> Enum.with_index(1)
        |> Enum.each(fn {participante, index} ->
          IO.puts("  #{index}. #{participante.nombre}")
          IO.puts("     Email: #{participante.correo}")
          IO.puts("     Habilidades: #{Enum.join(participante.habilidades, ", ")}")

          estado = case participante.equipo_id do
            nil -> "Sin equipo asignado"
            equipo_id ->
              case GestionEquipos.obtener_equipo(equipo_id) do
                {:ok, equipo} -> "Equipo: #{equipo.nombre}"
                _ -> "Equipo: #{equipo_id}"
              end
          end

          IO.puts("     Estado: #{estado}")
          IO.puts("")
        end)

      _ ->
        IO.puts("  Error al listar participantes\n")
    end

    pausar()
  end

defp ver_mentores do
  IO.puts("\n")
  IO.puts("===============================================")
  IO.puts("            MENTORES REGISTRADOS              ")
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
        IO.puts("     Email: #{mentor.correo}")
        IO.puts("     Equipos asignados: #{length(mentor.equipos_asignados)}/#{mentor.max_equipos}")

        # Mostrar nombres de equipos asignados
        if length(mentor.equipos_asignados) > 0 do
          IO.puts("     Equipos:")
          Enum.each(mentor.equipos_asignados, fn equipo_id ->
            case GestionEquipos.obtener_equipo(equipo_id) do
              {:ok, equipo} ->
                IO.puts("       • #{equipo.nombre}")
              _ ->
                IO.puts("       • ID: #{equipo_id}")
            end
          end)
        end

        IO.puts("     Disponible: #{if mentor.disponible, do: "Si", else: "No"}")
        IO.puts("")
      end)

    _ ->
      IO.puts("  Error al listar mentores\n")
  end

  pausar()
end

  # ========== REGISTROS ==========

  defp registrar_participante do
    IO.puts("\n=== REGISTRAR NUEVO PARTICIPANTE ===\n")

    nombre = IO.gets("Nombre completo: ") |> String.trim()
    correo = IO.gets("Correo electronico: ") |> String.trim()

    IO.puts("\nHabilidades (separadas por comas):")
    IO.puts("Ejemplo: Python, JavaScript, React")
    habilidades_str = IO.gets("> ") |> String.trim()

    habilidades = if habilidades_str == "" do
      []
    else
      habilidades_str
      |> String.split(",")
      |> Enum.map(&String.trim/1)
    end

    IO.puts("\nCree una contraseña (minimo 6 caracteres):")
    password = IO.gets("> ") |> String.trim()

    case GestionParticipantes.registrar_participante(%{
      nombre: nombre,
      correo: correo,
      habilidades: habilidades,
      password: password
    }) do
      {:ok, participante} ->
        IO.puts("\n+ Participante '#{participante.nombre}' registrado exitosamente!")
        IO.puts("  ID: #{participante.id}")
        IO.puts("  Correo: #{participante.correo}\n")
      {:error, razon} ->
        IO.puts("\nX Error: #{razon}\n")
    end

    pausar()
  end

  defp registrar_mentor do
    IO.puts("\n=== REGISTRAR NUEVO MENTOR ===\n")

    nombre = IO.gets("Nombre completo: ") |> String.trim()
    correo = IO.gets("Correo electronico: ") |> String.trim()
    especialidad = IO.gets("Especialidad: ") |> String.trim()

    IO.puts("\nCree una contraseña (minimo 6 caracteres):")
    password = IO.gets("> ") |> String.trim()

    case GestionMentores.registrar_mentor(%{
      nombre: nombre,
      correo: correo,
      especialidad: especialidad,
      password: password
    }) do
      {:ok, mentor} ->
        IO.puts("\n+ Mentor '#{mentor.nombre}' registrado exitosamente!")
        IO.puts("  ID: #{mentor.id}")
        IO.puts("  Correo: #{mentor.correo}")
        IO.puts("  Especialidad: #{mentor.especialidad}\n")
      {:error, razon} ->
        IO.puts("\nX Error: #{razon}\n")
    end

    pausar()
  end

  defp unirse_equipo do
    IO.puts("\n=== UNIRSE A UN EQUIPO ===\n")

    IO.puts("Ingrese su correo electronico:")
    correo = IO.gets("> ") |> String.trim()

    case GestionParticipantes.buscar_por_correo(correo) do
      {:ok, participante} ->
        if participante.equipo_id do
          case GestionEquipos.obtener_equipo(participante.equipo_id) do
            {:ok, equipo} ->
              IO.puts("\nYa perteneces al equipo '#{equipo.nombre}'.\n")
            _ ->
              IO.puts("\nYa tienes un equipo asignado.\n")
          end
        else
          # Mostrar equipos disponibles
          case GestionEquipos.listar_equipos_activos() do
            {:ok, [_|_] = equipos} ->
              IO.puts("\nEquipos disponibles:\n")

              equipos
              |> Enum.with_index(1)
              |> Enum.each(fn {equipo, index} ->
                espacios = equipo.max_miembros - length(equipo.miembros)
                IO.puts("  #{index}. #{equipo.nombre} (#{espacios} espacios disponibles)")
                IO.puts("     Tema: #{equipo.tema}")
                IO.puts("")
              end)

              IO.puts("Seleccione el numero del equipo:")
              opcion = IO.gets("> ") |> String.trim()

              case Integer.parse(opcion) do
                {index, _} when index > 0 and index <= length(equipos) ->
                  equipo = Enum.at(equipos, index - 1)

                  case GestionParticipantes.unirse_a_equipo(participante.id, equipo.id) do
                    {:ok, _} ->
                      IO.puts("\n+ Te has unido exitosamente al equipo '#{equipo.nombre}'!\n")
                    {:error, razon} ->
                      IO.puts("\nX Error: #{razon}\n")
                  end

                _ ->
                  IO.puts("\nOpcion invalida.\n")
              end

            {:ok, []} ->
              IO.puts("\nNo hay equipos disponibles en este momento.\n")

            _ ->
              IO.puts("\nError al obtener equipos.\n")
          end
        end

      {:error, :no_encontrado} ->
        IO.puts("\nParticipante no encontrado con el correo '#{correo}'.")
        IO.puts("Registrese primero usando la opcion 7.\n")

      _ ->
        IO.puts("\nError al buscar participante.\n")
    end

    pausar()
  end

  defp crear_equipo do
    IO.puts("\n=== CREAR NUEVO EQUIPO ===\n")

    nombre = IO.gets("Nombre del equipo: ") |> String.trim()
    tema = IO.gets("Tema del proyecto: ") |> String.trim()

    IO.puts("\nCategorias disponibles:")
    IO.puts("  1. Social")
    IO.puts("  2. Ambiental")
    IO.puts("  3. Educativo")
    IO.puts("  4. Salud")
    IO.puts("  5. Tecnologia")
    IO.puts("  6. Otro")

    categoria_opcion = IO.gets("\nSeleccione categoria: ") |> String.trim()

    categoria = case categoria_opcion do
      "1" -> :social
      "2" -> :ambiental
      "3" -> :educativo
      "4" -> :salud
      "5" -> :tecnologia
      "6" -> :otro
      _ -> nil
    end

    if categoria do
      case GestionEquipos.crear_equipo(%{nombre: nombre, tema: tema, categoria: categoria}) do
        {:ok, equipo} ->
          IO.puts("\n+ Equipo '#{equipo.nombre}' creado exitosamente!")
          IO.puts("  ID: #{equipo.id}")
          IO.puts("  Tema: #{equipo.tema}")
          IO.puts("  Categoria: #{equipo.categoria}\n")
        {:error, razon} ->
          IO.puts("\nX Error: #{razon}\n")
      end
    else
      IO.puts("\nX Categoria invalida\n")
    end

    pausar()
  end

  defp crear_proyecto do
    IO.puts("\n=== CREAR NUEVO PROYECTO ===\n")

    case GestionEquipos.listar_equipos() do
      {:ok, [_|_] = equipos} ->
        IO.puts("Equipos disponibles:\n")

        equipos
        |> Enum.with_index(1)
        |> Enum.each(fn {equipo, index} ->
          IO.puts("  #{index}. #{equipo.nombre}")
        end)

        IO.puts("\nSeleccione el numero del equipo:")
        equipo_opcion = IO.gets("> ") |> String.trim()

        case Integer.parse(equipo_opcion) do
          {index, _} when index > 0 and index <= length(equipos) ->
            equipo = Enum.at(equipos, index - 1)

            nombre = IO.gets("\nNombre del proyecto: ") |> String.trim()

            IO.puts("Descripcion (minimo 20 caracteres):")
            descripcion = IO.gets("> ") |> String.trim()

            IO.puts("\nCategorias: 1.Social 2.Ambiental 3.Educativo 4.Salud 5.Tecnologia 6.Otro")
            cat_opcion = IO.gets("Categoria: ") |> String.trim()

            categoria = case cat_opcion do
              "1" -> :social
              "2" -> :ambiental
              "3" -> :educativo
              "4" -> :salud
              "5" -> :tecnologia
              "6" -> :otro
              _ -> nil
            end

            if categoria do
              case GestionProyectos.registrar_proyecto(%{
                nombre: nombre,
                descripcion: descripcion,
                categoria: categoria,
                equipo_id: equipo.id
              }) do
                {:ok, proyecto} ->
                  IO.puts("\n+ Proyecto '#{proyecto.nombre}' creado exitosamente!")
                  IO.puts("  Equipo: #{equipo.nombre}")
                  IO.puts("  Estado: #{proyecto.estado}\n")
                {:error, razon} ->
                  IO.puts("\nX Error: #{razon}\n")
              end
            else
              IO.puts("\nX Categoria invalida\n")
            end

          _ ->
            IO.puts("\nOpcion invalida.\n")
        end

      {:ok, []} ->
        IO.puts("No hay equipos disponibles. Cree un equipo primero (opcion 9).\n")

      _ ->
        IO.puts("Error al obtener equipos.\n")
    end

    pausar()
  end

  # ========== COLABORACION ==========

  defp agregar_avance do
    IO.puts("\n=== AGREGAR AVANCE A PROYECTO ===\n")

    case GestionProyectos.listar_proyectos() do
      {:ok, [_|_] = proyectos} ->
        proyectos
        |> Enum.with_index(1)
        |> Enum.each(fn {proyecto, index} ->
          IO.puts("  #{index}. #{proyecto.nombre} [#{proyecto.estado}]")
        end)

        IO.puts("\nSeleccione el numero del proyecto:")
        proyecto_opcion = IO.gets("> ") |> String.trim()

        case Integer.parse(proyecto_opcion) do
          {index, _} when index > 0 and index <= length(proyectos) ->
            proyecto = Enum.at(proyectos, index - 1)

            IO.puts("\nDescripcion del avance:")
            avance = IO.gets("> ") |> String.trim()

            case GestionProyectos.agregar_avance(proyecto.id, avance) do
              {:ok, _} ->
                IO.puts("\n+ Avance agregado exitosamente al proyecto '#{proyecto.nombre}'!\n")
              {:error, razon} ->
                IO.puts("\nX Error: #{razon}\n")
            end

          _ ->
            IO.puts("\nOpcion invalida.\n")
        end

      {:ok, []} ->
        IO.puts("No hay proyectos disponibles.\n")

      _ ->
        IO.puts("Error al obtener proyectos.\n")
    end

    pausar()
  end

  defp ver_chat_equipo do
    IO.puts("\n=== CHAT DE EQUIPO ===\n")

    case GestionEquipos.listar_equipos() do
      {:ok, [_|_] = equipos} ->
        equipos
        |> Enum.with_index(1)
        |> Enum.each(fn {equipo, index} ->
          IO.puts("  #{index}. #{equipo.nombre}")
        end)

        IO.puts("\nSeleccione el numero del equipo:")
        equipo_opcion = IO.gets("> ") |> String.trim()

        case Integer.parse(equipo_opcion) do
          {index, _} when index > 0 and index <= length(equipos) ->
            equipo = Enum.at(equipos, index - 1)
            canal = "equipo_#{equipo.id}"

            case SistemaChat.obtener_historial(canal) do
              {:ok, mensajes} ->
                IO.puts("\n--- Mensajes de '#{equipo.nombre}' ---\n")

                if Enum.empty?(mensajes) do
                  IO.puts("  No hay mensajes aun.\n")
                else
                  Enum.each(mensajes, fn mensaje ->
                    fecha = Calendar.strftime(mensaje.fecha, "%d/%m %H:%M")
                    IO.puts("  [#{fecha}] #{String.slice(mensaje.emisor_id, 0..7)}: #{mensaje.contenido}")
                  end)
                  IO.puts("")
                end

              _ ->
                IO.puts("Error al obtener mensajes\n")
            end

          _ ->
            IO.puts("\nOpcion invalida.\n")
        end

      {:ok, []} ->
        IO.puts("No hay equipos disponibles.\n")

      _ ->
        IO.puts("Error al obtener equipos.\n")
    end

    pausar()
  end

  defp enviar_mensaje_chat do
    IO.puts("\n=== ENVIAR MENSAJE A EQUIPO ===\n")

    IO.puts("Ingrese su correo electronico:")
    correo = IO.gets("> ") |> String.trim()

    case GestionParticipantes.buscar_por_correo(correo) do
      {:ok, participante} ->
        if participante.equipo_id do
          case GestionEquipos.obtener_equipo(participante.equipo_id) do
            {:ok, equipo} ->
              IO.puts("\nEquipo: #{equipo.nombre}")
              IO.puts("Escriba su mensaje:")
              mensaje = IO.gets("> ") |> String.trim()

              if String.length(mensaje) > 0 do
                canal = "equipo_#{equipo.id}"

                case SistemaChat.enviar_mensaje(participante.id, mensaje, canal) do
                  {:ok, _} ->
                    IO.puts("\n+ Mensaje enviado exitosamente!\n")
                  _ ->
                    IO.puts("\nX Error al enviar mensaje\n")
                end
              else
                IO.puts("\nMensaje vacio. No se envio nada.\n")
              end

            _ ->
              IO.puts("\nError al obtener equipo.\n")
          end
        else
          IO.puts("\nNo estas asignado a ningun equipo. Unete a uno primero (opcion 8).\n")
        end

      {:error, :no_encontrado} ->
        IO.puts("\nParticipante no encontrado. Registrese primero (opcion 7).\n")

      _ ->
        IO.puts("\nError al buscar participante.\n")
    end

    pausar()
  end

  # ========== ELIMINACION ==========

  defp eliminar_participante do
    case verificar_acceso_admin() do
      {:ok, :autorizado} ->
        IO.puts("\n=== ELIMINAR PARTICIPANTE ===\n")

        case GestionParticipantes.listar_participantes() do
          {:ok, [_|_] = participantes} ->
            participantes
            |> Enum.with_index(1)
            |> Enum.each(fn {p, index} ->
              IO.puts("  #{index}. #{p.nombre} (#{p.correo})")
            end)

            IO.puts("\nSeleccione el numero del participante a eliminar:")
            opcion = IO.gets("> ") |> String.trim()

            case Integer.parse(opcion) do
              {index, _} when index > 0 and index <= length(participantes) ->
                participante = Enum.at(participantes, index - 1)

                IO.puts("\nEsta seguro de eliminar a '#{participante.nombre}'? (si/no)")
                confirmacion = IO.gets("> ") |> String.trim() |> String.downcase()

                if confirmacion == "si" do
                  case GestionParticipantes.eliminar_participante(participante.id) do
                    {:ok, :eliminado} ->
                      IO.puts("\n+ Participante eliminado exitosamente\n")
                    {:error, razon} ->
                      IO.puts("\nX Error: #{razon}\n")
                  end
                else
                  IO.puts("\nOperacion cancelada\n")
                end

              _ ->
                IO.puts("\nOpcion invalida\n")
            end

          {:ok, []} ->
            IO.puts("No hay participantes registrados\n")

          _ ->
            IO.puts("Error al listar participantes\n")
        end

      {:error, :no_autorizado} ->
        :ok
    end

    pausar()
  end

  defp eliminar_mentor do
    case verificar_acceso_admin() do
      {:ok, :autorizado} ->
        IO.puts("\n=== ELIMINAR MENTOR ===\n")

        case GestionMentores.listar_mentores() do
         {:ok, [_|_] = mentores} ->
            mentores
            |> Enum.with_index(1)
            |> Enum.each(fn {m, index} ->
              IO.puts("  #{index}. #{m.nombre} (#{m.correo})")
            end)

            IO.puts("\nSeleccione el numero del mentor a eliminar:")
            opcion = IO.gets("> ") |> String.trim()

            case Integer.parse(opcion) do
              {index, _} when index > 0 and index <= length(mentores) ->
                mentor = Enum.at(mentores, index - 1)

                IO.puts("\nEsta seguro de eliminar a '#{mentor.nombre}'? (si/no)")
                confirmacion = IO.gets("> ") |> String.trim() |> String.downcase()

                if confirmacion == "si" do
                  case GestionMentores.eliminar_mentor(mentor.id) do
                    {:ok, :eliminado} ->
                      IO.puts("\n+ Mentor eliminado exitosamente\n")
                    {:error, razon} ->
                      IO.puts("\nX Error: #{razon}\n")
                  end
                else
                  IO.puts("\nOperacion cancelada\n")
                end

              _ ->
                IO.puts("\nOpcion invalida\n")
            end

          {:ok, []} ->
            IO.puts("No hay mentores registrados\n")

          _ ->
            IO.puts("Error al listar mentores\n")
        end

      {:error, :no_autorizado} ->
        :ok
    end

    pausar()
  end

  defp eliminar_equipo do
    IO.puts("\n=== ELIMINAR EQUIPO ===\n")

    case GestionEquipos.listar_equipos() do
      {:ok, [_|_] = equipos} ->
        equipos
        |> Enum.with_index(1)
        |> Enum.each(fn {e, index} ->
          IO.puts("  #{index}. #{e.nombre}")
        end)

        IO.puts("\nSeleccione el numero del equipo a eliminar:")
        opcion = IO.gets("> ") |> String.trim()

        case Integer.parse(opcion) do
          {index, _} when index > 0 and index <= length(equipos) ->
            equipo = Enum.at(equipos, index - 1)

            IO.puts("\nEsta seguro de eliminar el equipo '#{equipo.nombre}'? (si/no)")
            confirmacion = IO.gets("> ") |> String.trim() |> String.downcase()

            if confirmacion == "si" do
              case GestionEquipos.eliminar_equipo(equipo.id) do
                {:ok, :eliminado} ->
                  IO.puts("\n+ Equipo eliminado exitosamente\n")
                {:error, razon} ->
                  IO.puts("\nX Error: #{razon}\n")
              end
            else
              IO.puts("\nOperacion cancelada\n")
            end

          _ ->
            IO.puts("\nOpcion invalida\n")
        end

      {:ok, []} ->
        IO.puts("No hay equipos registrados\n")

      _ ->
        IO.puts("Error al listar equipos\n")
    end

    pausar()
  end

  defp eliminar_proyecto do
    IO.puts("\n=== ELIMINAR PROYECTO ===\n")

    case GestionProyectos.listar_proyectos() do
      {:ok, [_|_] = proyectos} ->
        proyectos
        |> Enum.with_index(1)
        |> Enum.each(fn {p, index} ->
          IO.puts("  #{index}. #{p.nombre} [#{p.estado}]")
        end)

        IO.puts("\nSeleccione el numero del proyecto a eliminar:")
        opcion = IO.gets("> ") |> String.trim()

        case Integer.parse(opcion) do
          {index, _} when index > 0 and index <= length(proyectos) ->
            proyecto = Enum.at(proyectos, index - 1)

            IO.puts("\nEsta seguro de eliminar el proyecto '#{proyecto.nombre}'? (si/no)")
            confirmacion = IO.gets("> ") |> String.trim() |> String.downcase()

            if confirmacion == "si" do
              case GestionProyectos.eliminar_proyecto(proyecto.id) do
                {:ok, :eliminado} ->
                  IO.puts("\n+ Proyecto eliminado exitosamente\n")
                {:error, razon} ->
                  IO.puts("\nX Error: #{razon}\n")
              end
            else
              IO.puts("\nOperacion cancelada\n")
            end

          _ ->
            IO.puts("\nOpcion invalida\n")
        end

      {:ok, []} ->
        IO.puts("No hay proyectos registrados\n")

      _ ->
        IO.puts("Error al listar proyectos\n")
    end

    pausar()
  end

  # ========== SISTEMA ==========


defp asignar_mentor_equipo do
  IO.puts("\n=== ASIGNAR MENTOR A EQUIPO ===\n")

  # Listar mentores disponibles
  case GestionMentores.listar_mentores() do
    {:ok, [_|_] = mentores} ->
      IO.puts("Mentores disponibles:\n")

      mentores
      |> Enum.with_index(1)
      |> Enum.each(fn {mentor, index} ->
        capacidad = mentor.max_equipos - length(mentor.equipos_asignados)
        estado = if capacidad > 0, do: "#{capacidad} espacios disponibles", else: "LLENO"
        IO.puts("  #{index}. #{mentor.nombre} - #{mentor.especialidad} (#{estado})")
      end)

      IO.puts("\nSeleccione el numero del mentor:")
      mentor_opcion = IO.gets("> ") |> String.trim()

      case Integer.parse(mentor_opcion) do
        {index, _} when index > 0 and index <= length(mentores) ->
          mentor = Enum.at(mentores, index - 1)

          # Verificar si tiene capacidad
          if length(mentor.equipos_asignados) >= mentor.max_equipos do
            IO.puts("\nX Este mentor ya tiene el maximo de equipos asignados (#{mentor.max_equipos}).\n")
          else
            # Listar equipos
            case GestionEquipos.listar_equipos() do
              {:ok, [_|_] = equipos} ->
                IO.puts("\nEquipos disponibles:\n")

                equipos
                |> Enum.with_index(1)
                |> Enum.each(fn {equipo, idx} ->
                  ya_asignado = equipo.id in mentor.equipos_asignados
                  estado = if ya_asignado, do: "(YA ASIGNADO)", else: ""
                  IO.puts("  #{idx}. #{equipo.nombre} - #{equipo.tema} #{estado}")
                end)

                IO.puts("\nSeleccione el numero del equipo:")
                equipo_opcion = IO.gets("> ") |> String.trim()

                case Integer.parse(equipo_opcion) do
                  {eq_idx, _} when eq_idx > 0 and eq_idx <= length(equipos) ->
                    equipo = Enum.at(equipos, eq_idx - 1)

                    case GestionMentores.asignar_a_equipo(mentor.id, equipo.id) do
                      {:ok, _} ->
                        IO.puts("\n+ Mentor '#{mentor.nombre}' asignado exitosamente al equipo '#{equipo.nombre}'!\n")
                      {:error, razon} ->
                        IO.puts("\nX Error: #{razon}\n")
                    end

                  _ ->
                    IO.puts("\nOpcion invalida.\n")
                end

              {:ok, []} ->
                IO.puts("\nNo hay equipos disponibles.\n")

              _ ->
                IO.puts("\nError al obtener equipos.\n")
            end
          end

        _ ->
          IO.puts("\nOpcion invalida.\n")
      end

    {:ok, []} ->
      IO.puts("No hay mentores registrados. Registre uno primero (opcion 11).\n")

    _ ->
      IO.puts("Error al obtener mentores.\n")
  end

  pausar()
end

defp cambiar_estado_proyecto do
  IO.puts("\n=== CAMBIAR ESTADO DE PROYECTO ===\n")

  case GestionProyectos.listar_proyectos() do
    {:ok, [_|_] = proyectos} ->
      IO.puts("Proyectos disponibles:\n")

      proyectos
      |> Enum.with_index(1)
      |> Enum.each(fn {proyecto, index} ->
        IO.puts("  #{index}. #{proyecto.nombre} [Estado actual: #{estado_texto(proyecto.estado)}]")
      end)

      IO.puts("\nSeleccione el numero del proyecto:")
      proyecto_opcion = IO.gets("> ") |> String.trim()

      case Integer.parse(proyecto_opcion) do
        {index, _} when index > 0 and index <= length(proyectos) ->
          proyecto = Enum.at(proyectos, index - 1)

          IO.puts("\n=== Proyecto: #{proyecto.nombre} ===")
          IO.puts("Estado actual: #{estado_texto(proyecto.estado)}\n")
          IO.puts("Seleccione el nuevo estado:")
          IO.puts("  1. Iniciado")
          IO.puts("  2. En Progreso")
          IO.puts("  3. Finalizado")
          IO.puts("  4. Presentado")

          estado_opcion = IO.gets("\n> ") |> String.trim()

          nuevo_estado = case estado_opcion do
            "1" -> :iniciado
            "2" -> :en_progreso
            "3" -> :finalizado
            "4" -> :presentado
            _ -> nil
          end

          if nuevo_estado do
            case GestionProyectos.cambiar_estado(proyecto.id, nuevo_estado) do
              {:ok, _} ->
                IO.puts("\n+ Estado del proyecto '#{proyecto.nombre}' cambiado a '#{estado_texto(nuevo_estado)}' exitosamente!\n")
              {:error, razon} ->
                IO.puts("\nX Error: #{razon}\n")
            end
          else
            IO.puts("\nX Estado invalido.\n")
          end

        _ ->
          IO.puts("\nOpcion invalida.\n")
      end

    {:ok, []} ->
      IO.puts("No hay proyectos disponibles. Cree uno primero (opcion 10).\n")

    _ ->
      IO.puts("Error al obtener proyectos.\n")
  end

  pausar()
end

defp mostrar_ayuda do
  IO.puts("\n")
  IO.puts("===============================================")
  IO.puts("            AYUDA - COMANDOS                  ")
  IO.puts("===============================================")
  IO.puts("")
  IO.puts("  COMANDOS DISPONIBLES:")
  IO.puts("")
  IO.puts("  /teams    - Listar todos los equipos")
  IO.puts("  /projects - Listar todos los proyectos")
  IO.puts("  /join     - Unirse a un equipo")
  IO.puts("  /chat     - Ver chat de equipo")
  IO.puts("  /help     - Mostrar esta ayuda")
  IO.puts("")
  IO.puts("  FLUJO RECOMENDADO:")
  IO.puts("  1. Registrarse como participante (opcion 7)")
  IO.puts("  2. Ver equipos disponibles (opcion 1)")
  IO.puts("  3. Unirse a un equipo (opcion 8)")
  IO.puts("  4. Colaborar en proyectos y chat")
  IO.puts("")
  IO.puts("  ACCESO ADMINISTRATIVO:")
  IO.puts("  - Ver/eliminar participantes y mentores")
  IO.puts("  - Contraseña: #{@password_acceso}")
  IO.puts("")
  IO.puts("===============================================")
  IO.puts("")

  pausar()
end

defp recargar_datos do
  IO.puts("\n")
  IO.puts("===============================================")
  IO.puts("         RESUMEN DE DATOS ACTUALES            ")
  IO.puts("===============================================")
  IO.puts("")

  # Participantes
  case GestionParticipantes.listar_participantes() do
    {:ok, participantes} ->
      IO.puts("👥 PARTICIPANTES: #{length(participantes)}")
      if length(participantes) > 0 do
        Enum.take(participantes, 5)
        |> Enum.each(fn p ->
          equipo = case p.equipo_id do
            nil -> "Sin equipo"
            equipo_id ->
              case GestionEquipos.obtener_equipo(equipo_id) do
                {:ok, eq} -> eq.nombre
                _ -> "Equipo desconocido"
              end
          end
          IO.puts("   • #{p.nombre} (#{p.correo}) - #{equipo}")
        end)
        if length(participantes) > 5 do
          IO.puts("   ... y #{length(participantes) - 5} más")
        end
      end
      IO.puts("")
    _ ->
      IO.puts(" PARTICIPANTES: 0\n")
  end

  # Mentores
  case GestionMentores.listar_mentores() do
    {:ok, mentores} ->
      IO.puts(" MENTORES: #{length(mentores)}")
      if length(mentores) > 0 do
        Enum.each(mentores, fn m ->
          IO.puts("    #{m.nombre} - #{m.especialidad}")
        end)
      end
      IO.puts("")
    _ ->
      IO.puts(" MENTORES: 0\n")
  end

  # Equipos
  case GestionEquipos.listar_equipos() do
    {:ok, equipos} ->
      IO.puts(" EQUIPOS: #{length(equipos)}")
      if length(equipos) > 0 do
        Enum.each(equipos, fn e ->
          IO.puts("   • #{e.nombre} (#{e.tema}) - #{length(e.miembros)} miembros")
        end)
      end
      IO.puts("")
    _ ->
      IO.puts(" EQUIPOS: 0\n")
  end

  # Proyectos
  case GestionProyectos.listar_proyectos() do
    {:ok, proyectos} ->
      IO.puts(" PROYECTOS: #{length(proyectos)}")
      if length(proyectos) > 0 do
        Enum.each(proyectos, fn p ->
          IO.puts("   • #{p.nombre} [#{p.estado}] - #{length(p.avances)} avances")
        end)
      end
      IO.puts("")
    _ ->
      IO.puts(" PROYECTOS: 0\n")
  end

  # Mensajes de chat
  case SistemaChat.obtener_estadisticas() do
    {:ok, stats} ->
      IO.puts(" MENSAJES: #{stats.mensajes_enviados}")
      IO.puts(" CANALES ACTIVOS: #{stats.canales_activos}")
      IO.puts("")
    _ ->
      IO.puts(" MENSAJES: 0\n")
  end

  IO.puts("===============================================")
  IO.puts(" Datos actualizados correctamente")
  IO.puts("===============================================")
  IO.puts("")

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
    IO.puts("     Avances registrados: #{length(proyecto.avances)}")

    if length(proyecto.avances) > 0 do
      IO.puts("     Ultimos avances:")
      Enum.take(proyecto.avances, 3)
      |> Enum.each(fn avance ->
        IO.puts("       - #{avance.contenido}")
      end)
    end

    IO.puts("     Retroalimentaciones: #{length(proyecto.retroalimentacion)}")

    if length(proyecto.retroalimentacion) > 0 do
      IO.puts("     Comentarios de mentores:")
      Enum.take(proyecto.retroalimentacion, 2)
      |> Enum.each(fn retro ->
        IO.puts("       - #{retro.comentario}")
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
