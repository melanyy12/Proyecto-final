defmodule Hackathon.Semilla do
  @moduledoc """
  Carga datos iniciales para la hackathon con contraseñas de ejemplo
  NOTA: Las contraseñas por defecto son "password123" para todos los usuarios
  """

  alias Hackathon.Services.{GestionEquipos, GestionProyectos, GestionParticipantes, GestionMentores}

  @password_default "password123"

  def cargar_datos do
    IO.puts("\n Cargando datos iniciales de la Hackathon...")

    # Limpiar datos anteriores
    limpiar_datos()

    # Cargar participantes
    participantes = cargar_participantes()
    IO.puts(" #{length(participantes)} participantes cargados")

    # Cargar mentores
    mentores = cargar_mentores()
    IO.puts(" #{length(mentores)} mentores cargados")

    # Cargar equipos
    equipos = cargar_equipos()
    IO.puts(" #{length(equipos)} equipos cargados")

    # Asignar participantes a equipos
    asignar_participantes_a_equipos(participantes, equipos)
    IO.puts(" Participantes asignados a equipos")

    # Cargar proyectos
    proyectos = cargar_proyectos(equipos)
    IO.puts(" #{length(proyectos)} proyectos cargados")

    # Agregar avances
    agregar_avances(proyectos)
    IO.puts(" Avances agregados a los proyectos")

    # Agregar retroalimentación
    agregar_retroalimentacion(proyectos, mentores)
    IO.puts(" Retroalimentacion de mentores agregada")

    IO.puts("\n CREDENCIALES DE ACCESO:")
    IO.puts("====================================")
    IO.puts("Contraseña para TODOS los usuarios: #{@password_default}")
    IO.puts("\nPARTICIPANTES:")
    Enum.each(participantes, fn p ->
      IO.puts("   #{p.correo}")
    end)
    IO.puts("\nMENTORES:")
    Enum.each(mentores, fn m ->
      IO.puts("   #{m.correo}")
    end)
    IO.puts("====================================\n")

    IO.puts(" Datos cargados exitosamente!\n")

    {:ok, %{equipos: equipos, proyectos: proyectos, participantes: participantes, mentores: mentores}}
  end

  defp limpiar_datos do
    File.rm("data/equipos.txt")
    File.rm("data/proyectos.txt")
    File.rm("data/participantes.txt")
    File.rm("data/mentores.txt")
    File.rm("data/mensajes.txt")
    :ok
  end

  defp cargar_participantes do
    participantes_data = [
      %{nombre: "Juan Perez", correo: "juan.perez@email.com", habilidades: ["Backend", "Elixir"], password: @password_default},
      %{nombre: "Maria Garcia", correo: "maria.garcia@email.com", habilidades: ["Frontend", "React"], password: @password_default},
      %{nombre: "Carlos Lopez", correo: "carlos.lopez@email.com", habilidades: ["IA", "Python"], password: @password_default},
      %{nombre: "Ana Martinez", correo: "ana.martinez@email.com", habilidades: ["UX/UI", "Figma"], password: @password_default},
      %{nombre: "Pedro Rodriguez", correo: "pedro.rodriguez@email.com", habilidades: ["DevOps", "Docker"], password: @password_default},
      %{nombre: "Laura Sanchez", correo: "laura.sanchez@email.com", habilidades: ["Data Science", "ML"], password: @password_default},
      %{nombre: "Diego Torres", correo: "diego.torres@email.com", habilidades: ["Mobile", "Flutter"], password: @password_default},
      %{nombre: "Sofia Ramirez", correo: "sofia.ramirez@email.com", habilidades: ["Backend", "Node.js"], password: @password_default},
      %{nombre: "Miguel Flores", correo: "miguel.flores@email.com", habilidades: ["QA", "Testing"], password: @password_default}
    ]

    Enum.map(participantes_data, fn attrs ->
      case GestionParticipantes.registrar_participante(attrs) do
        {:ok, participante} -> participante
        _ -> nil
      end
    end)
    |> Enum.reject(&is_nil/1)
  end

  defp cargar_mentores do
    mentores_data = [
      %{nombre: "Dr. Roberto Garcia", correo: "roberto.garcia@mentor.com", especialidad: "Inteligencia Artificial", password: @password_default},
      %{nombre: "Ing. Patricia Lopez", correo: "patricia.lopez@mentor.com", especialidad: "Desarrollo Backend", password: @password_default},
      %{nombre: "Arq. Fernando Ruiz", correo: "fernando.ruiz@mentor.com", especialidad: "Arquitectura de Software", password: @password_default}
    ]

    Enum.map(mentores_data, fn attrs ->
      case GestionMentores.registrar_mentor(attrs) do
        {:ok, mentor} -> mentor
        _ -> nil
      end
    end)
    |> Enum.reject(&is_nil/1)
  end

  defp cargar_equipos do
    equipos_data = [
      %{nombre: "Los Innovadores", tema: "IA en Educacion", categoria: :educativo},
      %{nombre: "EcoTech", tema: "Reciclaje Inteligente", categoria: :ambiental},
      %{nombre: "Health Plus", tema: "Telemedicina Rural", categoria: :salud}
    ]

    Enum.map(equipos_data, fn attrs ->
      case GestionEquipos.crear_equipo(attrs) do
        {:ok, equipo} -> equipo
        _ -> nil
      end
    end)
    |> Enum.reject(&is_nil/1)
  end

  defp asignar_participantes_a_equipos(participantes, equipos) do
    # Asignar 3 participantes por equipo
    participantes
    |> Enum.with_index()
    |> Enum.each(fn {participante, index} ->
      equipo_index = rem(index, length(equipos))
      equipo = Enum.at(equipos, equipo_index)

      if equipo do
        GestionParticipantes.unirse_a_equipo(participante.id, equipo.id)
      end
    end)
  end

  defp cargar_proyectos(equipos) do
    proyectos_data = [
      %{
        nombre: "EduIA Platform",
        descripcion: "Plataforma educativa con inteligencia artificial que personaliza el aprendizaje segun el ritmo y estilo de cada estudiante",
        categoria: :educativo,
        equipo_id: Enum.at(equipos, 0).id
      },
      %{
        nombre: "RecycleAI",
        descripcion: "Sistema de reconocimiento de materiales reciclables usando vision por computadora para clasificacion automatica de residuos",
        categoria: :ambiental,
        equipo_id: Enum.at(equipos, 1).id
      },
      %{
        nombre: "TeleMed Connect",
        descripcion: "Plataforma de telemedicina que conecta pacientes en zonas rurales con medicos especialistas mediante consultas virtuales",
        categoria: :salud,
        equipo_id: Enum.at(equipos, 2).id
      }
    ]

    Enum.map(proyectos_data, fn attrs ->
      case GestionProyectos.registrar_proyecto(attrs) do
        {:ok, proyecto} -> proyecto
        _ -> nil
      end
    end)
    |> Enum.reject(&is_nil/1)
  end

  defp agregar_avances(proyectos) do
    # Proyecto 1: EduIA Platform
    if proyecto = Enum.at(proyectos, 0) do
      GestionProyectos.agregar_avance(proyecto.id, "Completamos el diseno de la arquitectura del sistema con modulos de IA y base de datos")
      GestionProyectos.agregar_avance(proyecto.id, "Implementamos el algoritmo de personalizacion de contenido usando machine learning")
      GestionProyectos.agregar_avance(proyecto.id, "Realizamos pruebas con 30 estudiantes, obteniendo 85% de satisfaccion")
      GestionProyectos.cambiar_estado(proyecto.id, :en_progreso)
    end

    # Proyecto 2: RecycleAI
    if proyecto = Enum.at(proyectos, 1) do
      GestionProyectos.agregar_avance(proyecto.id, "Entrenamos modelo de vision por computadora con 10,000 imagenes de residuos")
      GestionProyectos.agregar_avance(proyecto.id, "Desarrollamos prototipo de app movil con clasificacion en tiempo real")
      GestionProyectos.agregar_avance(proyecto.id, "Alcanzamos 92% de precision en clasificacion de 5 tipos de materiales")
      GestionProyectos.cambiar_estado(proyecto.id, :finalizado)
    end

    # Proyecto 3: TeleMed Connect
    if proyecto = Enum.at(proyectos, 2) do
      GestionProyectos.agregar_avance(proyecto.id, "Implementamos sistema de videollamadas con encriptacion end-to-end")
      GestionProyectos.agregar_avance(proyecto.id, "Integramos sistema de historias clinicas digitales")
      GestionProyectos.cambiar_estado(proyecto.id, :en_progreso)
    end
  end

  defp agregar_retroalimentacion(proyectos, mentores) do
    # Retroalimentación para proyecto 1
    if proyecto = Enum.at(proyectos, 0) do
      if mentor = Enum.at(mentores, 0) do
        GestionProyectos.agregar_retroalimentacion(
          proyecto.id,
          mentor.id,
          "Excelente arquitectura. Recomiendo agregar mas casos de prueba para el algoritmo de ML"
        )
      end

      if mentor = Enum.at(mentores, 1) do
        GestionProyectos.agregar_retroalimentacion(
          proyecto.id,
          mentor.id,
          "El diseno de base de datos es solido. Consideren implementar cache para mejorar performance"
        )
      end
    end

    # Retroalimentación para proyecto 2
    if proyecto = Enum.at(proyectos, 1) do
      if mentor = Enum.at(mentores, 0) do
        GestionProyectos.agregar_retroalimentacion(
          proyecto.id,
          mentor.id,
          "Impresionante precision del modelo. Proyecto listo para presentacion final"
        )
      end
    end

    # Retroalimentación para proyecto 3
    if proyecto = Enum.at(proyectos, 2) do
      if mentor = Enum.at(mentores, 2) do
        GestionProyectos.agregar_retroalimentacion(
          proyecto.id,
          mentor.id,
          "Seguridad bien implementada. Sugiero agregar funcionalidad de recetas digitales"
        )
      end
    end
  end
end
