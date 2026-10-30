# España · primer curso · semestre 1 · 2026-10-30

Material de entrenamiento original, no exámenes oficiales ni apuntes de UVic. El plan público UVic confirma cinco materias: Anatomía I, Fisiología I, Fundamentos de la Fisioterapia, Psicología y Cultura, Sociedad y Salud. ES1 en la app significa primer año, no primer semestre.

## Contenido
- 3 fichas existentes reescritas en castellano: tejidos y membranas; transporte celular; razonamiento e intervención.
- 2 materias añadidas con una ficha cada una: Psicología; Cultura, Sociedad y Salud.
- 50 preguntas originales: 39 QCM y 11 casos de aplicación; cuatro opciones, una correcta, corrección y URL fuente.
- Los bloques añadidos no cubren la totalidad de los cinco programas. Revisión docente externa pendiente.
- Las fuentes UVic establecen el alcance curricular. OpenStax y OMS fundamentan los contenidos específicos enlazados.
- No se han actualizado los PDF anteriores: las fichas HTML y sus fuentes son la versión revisada. Los PDF previos se conservan en la copia de seguridad.

## Verificación
- Comprobación de estructura y de 50 textos únicos.
- Comparación con preguntas existentes: cero duplicados textuales para este lote.
- Importación completa dentro de transacción y ROLLBACK: pasa.
- Lectura con rol authenticated y asignación España existente: 50 preguntas y 5 fichas accesibles.
- RPC de preguntas oculta correcciones e indicadores correct antes de responder: pasa.
- Rollback ensayado en transacción: restaura las 3 fichas previas y despublica las 50 preguntas.
- Ninguna modificación de esquema, autenticación, progreso ni cuentas. Sin cambio de código frontend.

## Aplicación
`publish.sql` aplica los datos en transacción y aborta si fallan las aserciones. IDs estables, comprobación de conflicto en las fichas. Publicación vía Supabase después de verificaciones.

## Retorno atrás
`rollback.sql` despublica el lote y desactiva las dos materias nuevas, preservando IDs y referencias de intentos. Restaura fichas anteriores solo si no han cambiado desde esta revisión. Revisar conflictos si ha habido edición posterior.
`bundle.json` contiene el nuevo contenido y las tres versiones previas.
