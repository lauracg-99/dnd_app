# Flutter Copilot Skills

Esta carpeta está preparada para añadir skills personalizadas de GitHub Copilot para este proyecto Flutter.

## Estructura

- `SKILL.md`: guía principal del agente para desarrollo en Flutter.
- `../firebase-auth/SKILL.md`: autenticación y Firebase.
- `../firebase-sync/SKILL.md`: sincronización entre Firebase y almacenamiento local.
- `../flutter-ui/SKILL.md`: widgets, layouts y navegación.
- `../flutter-testing/SKILL.md`: tests y regresión.
- `../flutter-performance/SKILL.md`: rendimiento y optimización.
- `../flutter-accessibility/SKILL.md`: accesibilidad y UX inclusiva.
- `../dnd-character-sheet/SKILL.md`: gestión de personajes y atributos de D&D.
- `../dnd-spell-reference/SKILL.md`: base de datos de conjuros y filtros.
- `../dnd-equipment-and-items/SKILL.md`: inventario, equipo y objetos.
- `../dnd-notes-and-diaries/SKILL.md`: notas, diarios y contenido narrativo.
- `../combat-and-rules/SKILL.md`: reglas de combate y cálculos del sistema.
- `../provider-state-management/SKILL.md`: estado global y Provider.
- `../user-account-and-security/SKILL.md`: seguridad, sesión, cuentas y privacidad.
- `../mobile-desktop-ux/SKILL.md`: UX responsive para móvil, web y desktop.

## Buenas prácticas aplicadas

- Mantener cambios pequeños y enfocados.
- Reutilizar la arquitectura actual del proyecto (`lib/helpers`, `lib/models`, `lib/services`, `lib/views`, `lib/widgets`, `lib/viewmodels`).
- Priorizar código seguro con Null Safety y `const` cuando corresponda.
- Validar con `flutter analyze`, `dart format` y pruebas relevantes antes de cerrar cambios.
- Escribir pruebas para comportamientos críticos y seguir una aproximación TDD.

## Cómo ampliar

Añade más archivos `SKILL.md` en esta carpeta cuando necesites habilidades específicas como:

- Firebase/Auth
- UI y diseño de widgets
- Testing y regresión
- Performance y optimización
- Accesibilidad
