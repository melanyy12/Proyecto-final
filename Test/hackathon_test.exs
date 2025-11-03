defmodule HackathonTest do
  use ExUnit.Case
  doctest Hackathon

  alias Hackathon.Services.{GestionEquipos, GestionProyectos, GestionParticipantes, GestionMentores, SistemaChat}
  alias Hackathon.Domain.{Equipo, Proyecto, Participante, Mentor}

  setup do
    # Limpiar datos antes de cada prueba
    File.rm("data/equipos.txt")
    File.rm("data/proyectos.txt")
    File.rm("data/participantes.txt")
    File.rm("data/mentores.txt")
    File.rm("data/mensajes.txt")
    :ok
  end

  describe "Gestión de Equipos" do
    test "crear equipo exitosamente" do
      {:ok, equipo} = GestionEquipos.crear_equipo(%{
        nombre: "Test Team",
        tema: "Testing App",
        categoria: :tecnologia
      })

      assert equipo.nombre == "Test Team"
      assert equipo.tema == "Testing App"
      assert equipo.categoria == :tecnologia
      assert equipo.activo == true
      assert length(equipo.miembros) == 0
    end

    test "validar nombre de equipo muy corto" do
      {:error, mensaje} = GestionEquipos.crear_equipo(%{
        nombre: "AB",
        tema: "Test",
        categoria: :tecnologia
      })

      assert String.contains?(mensaje, "Nombre debe tener entre")
    end

    test "agregar miembro a equipo" do
      {:ok, equipo} = GestionEquipos.crear_equipo(%{
        nombre: "Team Alpha",
        tema: "AI Project",
        categoria: :tecnologia
      })

      {:ok, equipo_actualizado} = GestionEquipos.agregar_miembro(equipo.id, "participante_1")

      assert length(equipo_actualizado.miembros) == 1
      assert "participante_1" in equipo_actualizado.miembros
    end

    test "no permitir equipo lleno" do
      {:ok, equipo} = GestionEquipos.crear_equipo(%{
        nombre: "Full Team",
        tema: "Test",
        categoria: :tecnologia
      })

      # Agregar 6 miembros (máximo)
      Enum.each(1..6, fn i ->
        GestionEquipos.agregar_miembro(equipo.id, "participante_#{i}")
      end)

      # Intentar agregar el séptimo
      {:error, mensaje} = GestionEquipos.agregar_miembro(equipo.id, "participante_7")

      assert String.contains?(mensaje, "lleno")
    end

    test "listar equipos" do
      GestionEquipos.crear_equipo(%{nombre: "Team 1", tema: "Test", categoria: :tecnologia})
      GestionEquipos.crear_equipo(%{nombre: "Team 2", tema: "Test", categoria: :salud})

      {:ok, equipos} = GestionEquipos.listar_equipos()

      assert length(equipos) == 2
    end
  end

  describe "Gestión de Proyectos" do
    test "crear proyecto exitosamente" do
      {:ok, equipo} = GestionEquipos.crear_equipo(%{
        nombre: "Dev Team",
        tema: "App",
        categoria: :tecnologia
      })

      {:ok, proyecto} = GestionProyectos.registrar_proyecto(%{
        nombre: "Super App",
        descripcion: "Una aplicacion increible que resuelve problemas reales de la comunidad",
        categoria: :tecnologia,
        equipo_id: equipo.id
      })

      assert proyecto.nombre == "Super App"
      assert proyecto.estado == :iniciado
      assert proyecto.equipo_id == equipo.id
    end

    test "validar descripción muy corta" do
      {:ok, equipo} = GestionEquipos.crear_equipo(%{
        nombre: "Team",
        tema: "Test",
        categoria: :tecnologia
      })

      {:error, mensaje} = GestionProyectos.registrar_proyecto(%{
        nombre: "Proyecto Test",
        descripcion: "Corto",
        categoria: :tecnologia,
        equipo_id: equipo.id
      })

      assert String.contains?(mensaje, "Descripción debe tener")
    end

    test "agregar avance a proyecto" do
      {:ok, equipo} = GestionEquipos.crear_equipo(%{
        nombre: "Team",
        tema: "Test",
        categoria: :tecnologia
      })

      {:ok, proyecto} = GestionProyectos.registrar_proyecto(%{
        nombre: "Proyecto",
        descripcion: "Descripcion suficientemente larga para pasar validacion",
        categoria: :tecnologia,
        equipo_id: equipo.id
      })

      {:ok, proyecto_actualizado} = GestionProyectos.agregar_avance(
        proyecto.id,
        "Completamos el primer sprint"
      )

      assert length(proyecto_actualizado.avances) == 1
      assert hd(proyecto_actualizado.avances).contenido == "Completamos el primer sprint"
    end

    test "cambiar estado de proyecto" do
      {:ok, equipo} = GestionEquipos.crear_equipo(%{
        nombre: "Team",
        tema: "Test",
        categoria: :tecnologia
      })

      {:ok, proyecto} = GestionProyectos.registrar_proyecto(%{
        nombre: "Proyecto",
        descripcion: "Descripcion suficientemente larga para validacion",
        categoria: :tecnologia,
        equipo_id: equipo.id
      })

      {:ok, proyecto_actualizado} = GestionProyectos.cambiar_estado(proyecto.id, :en_progreso)

      assert proyecto_actualizado.estado == :en_progreso
    end

    test "filtrar proyectos por categoría" do
      {:ok, equipo1} = GestionEquipos.crear_equipo(%{nombre: "Team 1", tema: "Test", categoria: :tecnologia})
      {:ok, equipo2} = GestionEquipos.crear_equipo(%{nombre: "Team 2", tema: "Test", categoria: :salud})

      GestionProyectos.registrar_proyecto(%{
        nombre: "Proyecto Tech",
        descripcion: "Descripcion larga sobre tecnologia para validacion",
        categoria: :tecnologia,
        equipo_id: equipo1.id
      })

      GestionProyectos.registrar_proyecto(%{
        nombre: "Proyecto Salud",
        descripcion: "Descripcion larga sobre salud para validacion",
        categoria: :salud,
        equipo_id: equipo2.id
      })

      {:ok, proyectos_tech} = GestionProyectos.consultar_por_categoria(:tecnologia)

      assert length(proyectos_tech) == 1
      assert hd(proyectos_tech).categoria == :tecnologia
    end
  end

  describe "Gestión de Participantes" do
    test "registrar participante exitosamente" do
      {:ok, participante} = GestionParticipantes.registrar_participante(%{
        nombre: "Juan Perez",
        correo: "juan@test.com",
        habilidades: ["Elixir", "Python"]
      })

      assert participante.nombre == "Juan Perez"
      assert participante.correo == "juan@test.com"
      assert length(participante.habilidades) == 2
      assert participante.equipo_id == nil
    end

    test "validar correo inválido" do
      {:error, mensaje} = GestionParticipantes.registrar_participante(%{
        nombre: "Test User",
        correo: "correo-invalido",
        habilidades: []
      })

      assert String.contains?(mensaje, "Correo electrónico inválido")
    end

    test "unirse a equipo" do
      {:ok, equipo} = GestionEquipos.crear_equipo(%{
        nombre: "Team Alpha",
        tema: "Test",
        categoria: :tecnologia
      })

      {:ok, participante} = GestionParticipantes.registrar_participante(%{
        nombre: "Maria Garcia",
        correo: "maria@test.com",
        habilidades: ["React"]
      })

      {:ok, participante_actualizado} = GestionParticipantes.unirse_a_equipo(
        participante.id,
        equipo.id
      )

      assert participante_actualizado.equipo_id == equipo.id
    end

    test "buscar participante por correo" do
      GestionParticipantes.registrar_participante(%{
        nombre: "Carlos Lopez",
        correo: "carlos@test.com",
        habilidades: []
      })

      {:ok, participante} = GestionParticipantes.buscar_por_correo("carlos@test.com")

      assert participante.nombre == "Carlos Lopez"
    end
  end

  describe "Gestión de Mentores" do
    test "registrar mentor exitosamente" do
      {:ok, mentor} = GestionMentores.registrar_mentor(%{
        nombre: "Dr. Smith",
        correo: "smith@mentor.com",
        especialidad: "Inteligencia Artificial"
      })

      assert mentor.nombre == "Dr. Smith"
      assert mentor.especialidad == "Inteligencia Artificial"
      assert mentor.disponible == true
      assert length(mentor.equipos_asignados) == 0
    end

    test "asignar mentor a equipo" do
      {:ok, equipo} = GestionEquipos.crear_equipo(%{
        nombre: "Team",
        tema: "Test",
        categoria: :tecnologia
      })

      {:ok, mentor} = GestionMentores.registrar_mentor(%{
        nombre: "Mentor Test",
        correo: "mentor@test.com",
        especialidad: "Backend"
      })

      {:ok, mentor_actualizado} = GestionMentores.asignar_a_equipo(mentor.id, equipo.id)

      assert length(mentor_actualizado.equipos_asignados) == 1
      assert equipo.id in mentor_actualizado.equipos_asignados
    end

    test "no asignar más equipos de los permitidos" do
      {:ok, mentor} = GestionMentores.registrar_mentor(%{
        nombre: "Mentor",
        correo: "mentor@test.com",
        especialidad: "Test"
      })

      # Crear y asignar 3 equipos (máximo)
      Enum.each(1..3, fn i ->
        {:ok, equipo} = GestionEquipos.crear_equipo(%{
          nombre: "Team #{i}",
          tema: "Test",
          categoria: :tecnologia
        })
        GestionMentores.asignar_a_equipo(mentor.id, equipo.id)
      end)

      # Intentar asignar un cuarto equipo
      {:ok, equipo4} = GestionEquipos.crear_equipo(%{
        nombre: "Team 4",
        tema: "Test",
        categoria: :tecnologia
      })

      {:error, mensaje} = GestionMentores.asignar_a_equipo(mentor.id, equipo4.id)

      assert String.contains?(mensaje, "máximo")
    end
  end

  describe "Sistema de Chat" do
    test "enviar mensaje a canal" do
      {:ok, mensaje} = SistemaChat.enviar_mensaje(
        "participante_1",
        "Hola equipo!",
        "equipo_123"
      )

      assert mensaje.emisor_id == "participante_1"
      assert mensaje.contenido == "Hola equipo!"
      assert mensaje.canal == "equipo_123"
    end

    test "obtener historial de canal" do
      canal = "equipo_test"

      SistemaChat.enviar_mensaje("user1", "Mensaje 1", canal)
      SistemaChat.enviar_mensaje("user2", "Mensaje 2", canal)
      SistemaChat.enviar_mensaje("user3", "Mensaje 3", canal)

      {:ok, mensajes} = SistemaChat.obtener_historial(canal)

      assert length(mensajes) == 3
    end

    test "mensajes separados por canal" do
      SistemaChat.enviar_mensaje("user1", "Canal A", "canal_a")
      SistemaChat.enviar_mensaje("user2", "Canal B", "canal_b")

      {:ok, mensajes_a} = SistemaChat.obtener_historial("canal_a")
      {:ok, mensajes_b} = SistemaChat.obtener_historial("canal_b")

      assert length(mensajes_a) == 1
      assert length(mensajes_b) == 1
      assert hd(mensajes_a).contenido == "Canal A"
      assert hd(mensajes_b).contenido == "Canal B"
    end
  end

  describe "Dominio - Entidades" do
    test "Equipo.nuevo crea equipo válido" do
      equipo = Equipo.nuevo("id1", "Team", "Theme", :tecnologia)

      assert equipo.id == "id1"
      assert equipo.nombre == "Team"
      assert equipo.activo == true
      assert equipo.miembros == []
    end

    test "Proyecto.nuevo crea proyecto válido" do
      proyecto = Proyecto.nuevo("id1", "Proyecto", "Descripcion", :tecnologia, "equipo1")

      assert proyecto.id == "id1"
      assert proyecto.estado == :iniciado
      assert proyecto.avances == []
    end

    test "Participante.nuevo crea participante válido" do
      participante = Participante.nuevo("id1", "Juan", "juan@test.com", ["Elixir"])

      assert participante.nombre == "Juan"
      assert participante.correo == "juan@test.com"
      assert participante.equipo_id == nil
    end

    test "Mentor.nuevo crea mentor válido" do
      mentor = Mentor.nuevo("id1", "Dr. Smith", "AI", "smith@test.com")

      assert mentor.nombre == "Dr. Smith"
      assert mentor.especialidad == "AI"
      assert mentor.disponible == true
    end
  end

  describe "Integración - Flujo completo" do
    test "flujo completo: crear equipo, proyecto, participante y agregar avances" do
      # 1. Crear equipo
      {:ok, equipo} = GestionEquipos.crear_equipo(%{
        nombre: "Innovadores",
        tema: "IA para educacion",
        categoria: :educativo
      })

      # 2. Registrar participante
      {:ok, participante} = GestionParticipantes.registrar_participante(%{
        nombre: "Ana Torres",
        correo: "ana@test.com",
        habilidades: ["Python", "ML"]
      })

      # 3. Unir participante a equipo
      {:ok, _} = GestionParticipantes.unirse_a_equipo(participante.id, equipo.id)

      # 4. Crear proyecto
      {:ok, proyecto} = GestionProyectos.registrar_proyecto(%{
        nombre: "EduAI",
        descripcion: "Plataforma educativa con inteligencia artificial para personalizar aprendizaje",
        categoria: :educativo,
        equipo_id: equipo.id
      })

      # 5. Agregar avances
      {:ok, _} = GestionProyectos.agregar_avance(proyecto.id, "Completado diseño de arquitectura")
      {:ok, proyecto_final} = GestionProyectos.agregar_avance(proyecto.id, "Implementado algoritmo ML")

      # 6. Registrar mentor y dar retroalimentación
      {:ok, mentor} = GestionMentores.registrar_mentor(%{
        nombre: "Dr. Garcia",
        correo: "garcia@mentor.com",
        especialidad: "Machine Learning"
      })

      {:ok, proyecto_con_retro} = GestionProyectos.agregar_retroalimentacion(
        proyecto.id,
        mentor.id,
        "Excelente progreso en el algoritmo"
      )

      # Verificaciones
      assert length(proyecto_final.avances) == 2
      assert length(proyecto_con_retro.retroalimentacion) == 1
      assert proyecto_con_retro.estado == :iniciado
    end
  end
end
