BEGIN;
UPDATE public.curriculum_quiz_questions SET is_published=false,updated_at=now() WHERE metadata->>'batch'='es-a1-ateliers-20261031';
UPDATE public.curriculum_lessons SET is_published=false,updated_at=now() WHERE id::text LIKE 'a7311031-%';
UPDATE public.curriculum_topics SET is_active=false,updated_at=now() WHERE id::text LIKE 'a7311031-%';
UPDATE public.curriculum_lessons SET content='### Objetivos

Organizar músculos por región y acción; distinguir estabilización, movimiento y relaciones de tendones extrínsecos e intrínsecos.

### Hombro y codo

El manguito rotador reúne supraespinoso, infraespinoso, redondo menor y subescapular, con tendones que contribuyen a estabilidad glenohumeral. Deltoides no es parte del manguito. El tríceps extiende el codo; braquial y bíceps participan en flexión. El bíceps también participa en supinación. Acción de un músculo y movimiento observado dependen de posición y coordinación.

### Antebrazo y mano

Los grupos anteriores del antebrazo incluyen muchos flexores y pronadores; los posteriores, extensores y supinadores. Un músculo extrínseco de mano tiene vientre fuera de ella y tendones que llegan a los dedos; uno intrínseco tiene origen y localización dentro de la mano. Los tendones no son nervios ni ligamentos.

### Tabla de orientación

| Estructura o grupo | Relación funcional básica |
|---|---|
| Manguito rotador | Estabilidad y acciones de rotación/elevación según músculo |
| Tríceps braquial | Extensión del codo |
| Bíceps braquial | Flexión del codo y supinación |
| Flexores extrínsecos de dedos | Vientres en antebrazo, tendones hacia mano |
| Músculos tenares | Movimientos del pulgar |
| Interóseos | Abducción y aducción de dedos respecto al eje de la mano |

Relaciona nombres con atlas y figuras originales enlazadas. Preparar el reconocimiento no demuestra que sepas palpar o aislar una contracción. Evita deducir una lesión nerviosa por un único movimiento doloroso.

### Repaso activo

Explica los conceptos sin mirar. En el cuestionario, justifica la respuesta y el error de las alternativas. Si hay cálculos, escribe fórmula, unidades y resultado. Anota las dudas y revísalas en otra sesión.

Entrenamiento original complementario al plan docente UVic 2026–2027; no son exámenes ni preguntas oficiales. La práctica clínica y las destrezas manuales requieren supervisión docente.',updated_at=now() WHERE id='f7301030-2026-4000-8002-000000000030' AND content='### Objetivos

Organizar músculos por región y acción; distinguir estabilización, movimiento y relaciones de tendones extrínsecos e intrínsecos.

### Hombro y codo

El manguito rotador reúne supraespinoso, infraespinoso, redondo menor y subescapular, con tendones que contribuyen a estabilidad glenohumeral. Deltoides no es parte del manguito. El tríceps extiende el codo; braquial y bíceps participan en flexión. El bíceps también participa en supinación. Acción de un músculo y movimiento observado dependen de posición y coordinación.

### Antebrazo y mano

Los grupos anteriores del antebrazo incluyen muchos flexores y pronadores; los posteriores, extensores y supinadores. Un músculo extrínseco de mano tiene vientre fuera de ella y tendones que llegan a los dedos; uno intrínseco tiene origen y localización dentro de la mano. Los tendones no son nervios ni ligamentos.

### Referencias de orientación

- Manguito rotador: Estabilidad y acciones de rotación/elevación según músculo
- Tríceps braquial: Extensión del codo
- Bíceps braquial: Flexión del codo y supinación
- Flexores extrínsecos de dedos: Vientres en antebrazo, tendones hacia mano
- Músculos tenares: Movimientos del pulgar
- Interóseos: Abducción y aducción de dedos respecto al eje de la mano

Relaciona nombres con atlas y figuras originales enlazadas. Preparar el reconocimiento no demuestra que sepas palpar o aislar una contracción. Evita deducir una lesión nerviosa por un único movimiento doloroso.

### Repaso activo

Explica los conceptos sin mirar. En el cuestionario, justifica la respuesta y el error de las alternativas. Si hay cálculos, escribe fórmula, unidades y resultado. Anota las dudas y revísalas en otra sesión.

Entrenamiento original complementario al plan docente UVic 2026–2027; no son exámenes ni preguntas oficiales. La práctica clínica y las destrezas manuales requieren supervisión docente.';
UPDATE public.curriculum_lessons SET content='### Objetivos

Ordenar grupos musculares y relacionar sus acciones con marcha, rodilla y tobillo sin atribuir una tarea completa a un solo músculo.

### Muslo

El cuádriceps comprende recto femoral y vastos lateral, medial e intermedio; todos participan en extensión de rodilla. El recto femoral también cruza cadera. Los isquiotibiales incluyen semitendinoso, semimembranoso y bíceps femoral; la cabeza corta del bíceps no cruza la cadera. La región medial del muslo contiene aductores.

### Pierna y tendones

El tibial anterior participa en dorsiflexión e inversión. Gastrocnemio y sóleo contribuyen a flexión plantar mediante el tendón calcáneo; gastrocnemio también cruza rodilla. Los fibulares contribuyen a eversión. El complejo tendinoso transmite fuerza; no produce por sí solo potenciales de acción ni contracción activa.

### Orientación y función

| Grupo o estructura | Acción o relación de estudio |
|---|---|
| Cuádriceps | Extensión de rodilla |
| Recto femoral | Cruza rodilla y cadera |
| Isquiotibiales | Flexión de rodilla, con diferencias entre componentes |
| Tibial anterior | Dorsiflexión e inversión |
| Gastrocnemio y sóleo | Flexión plantar |
| Fibulares | Eversión |

El pie combina músculos extrínsecos e intrínsecos. Los tendones hacia dedos y arcos no se comprenden como piezas aisladas de la marcha. Revisa figuras enlazadas y explica qué articulaciones cruza cada músculo antes de memorizar una acción. La palpación y valoración de fuerza necesitan práctica supervisada.

### Repaso activo

Explica los conceptos sin mirar. En el cuestionario, justifica la respuesta y el error de las alternativas. Si hay cálculos, escribe fórmula, unidades y resultado. Anota las dudas y revísalas en otra sesión.

Entrenamiento original complementario al plan docente UVic 2026–2027; no son exámenes ni preguntas oficiales. La práctica clínica y las destrezas manuales requieren supervisión docente.',updated_at=now() WHERE id='f7301030-2026-4000-8002-000000000031' AND content='### Objetivos

Ordenar grupos musculares y relacionar sus acciones con marcha, rodilla y tobillo sin atribuir una tarea completa a un solo músculo.

### Muslo

El cuádriceps comprende recto femoral y vastos lateral, medial e intermedio; todos participan en extensión de rodilla. El recto femoral también cruza cadera. Los isquiotibiales incluyen semitendinoso, semimembranoso y bíceps femoral; la cabeza corta del bíceps no cruza la cadera. La región medial del muslo contiene aductores.

### Pierna y tendones

El tibial anterior participa en dorsiflexión e inversión. Gastrocnemio y sóleo contribuyen a flexión plantar mediante el tendón calcáneo; gastrocnemio también cruza rodilla. Los fibulares contribuyen a eversión. El complejo tendinoso transmite fuerza; no produce por sí solo potenciales de acción ni contracción activa.

### Orientación y función

- Cuádriceps: Extensión de rodilla
- Recto femoral: Cruza rodilla y cadera
- Isquiotibiales: Flexión de rodilla, con diferencias entre componentes
- Tibial anterior: Dorsiflexión e inversión
- Gastrocnemio y sóleo: Flexión plantar
- Fibulares: Eversión

El pie combina músculos extrínsecos e intrínsecos. Los tendones hacia dedos y arcos no se comprenden como piezas aisladas de la marcha. Revisa figuras enlazadas y explica qué articulaciones cruza cada músculo antes de memorizar una acción. La palpación y valoración de fuerza necesitan práctica supervisada.

### Repaso activo

Explica los conceptos sin mirar. En el cuestionario, justifica la respuesta y el error de las alternativas. Si hay cálculos, escribe fórmula, unidades y resultado. Anota las dudas y revísalas en otra sesión.

Entrenamiento original complementario al plan docente UVic 2026–2027; no son exámenes ni preguntas oficiales. La práctica clínica y las destrezas manuales requieren supervisión docente.';
DO $$ BEGIN IF EXISTS(SELECT 1 FROM public.curriculum_topics WHERE id::text LIKE 'a7311031-%' AND is_active) OR EXISTS(SELECT 1 FROM public.curriculum_quiz_questions WHERE metadata->>'batch'='es-a1-ateliers-20261031' AND is_published) THEN RAISE EXCEPTION 'Rollback active rows'; END IF;IF NOT EXISTS(SELECT 1 FROM public.curriculum_lessons WHERE id='f7301030-2026-4000-8002-000000000030' AND content='### Objetivos

Organizar músculos por región y acción; distinguir estabilización, movimiento y relaciones de tendones extrínsecos e intrínsecos.

### Hombro y codo

El manguito rotador reúne supraespinoso, infraespinoso, redondo menor y subescapular, con tendones que contribuyen a estabilidad glenohumeral. Deltoides no es parte del manguito. El tríceps extiende el codo; braquial y bíceps participan en flexión. El bíceps también participa en supinación. Acción de un músculo y movimiento observado dependen de posición y coordinación.

### Antebrazo y mano

Los grupos anteriores del antebrazo incluyen muchos flexores y pronadores; los posteriores, extensores y supinadores. Un músculo extrínseco de mano tiene vientre fuera de ella y tendones que llegan a los dedos; uno intrínseco tiene origen y localización dentro de la mano. Los tendones no son nervios ni ligamentos.

### Tabla de orientación

| Estructura o grupo | Relación funcional básica |
|---|---|
| Manguito rotador | Estabilidad y acciones de rotación/elevación según músculo |
| Tríceps braquial | Extensión del codo |
| Bíceps braquial | Flexión del codo y supinación |
| Flexores extrínsecos de dedos | Vientres en antebrazo, tendones hacia mano |
| Músculos tenares | Movimientos del pulgar |
| Interóseos | Abducción y aducción de dedos respecto al eje de la mano |

Relaciona nombres con atlas y figuras originales enlazadas. Preparar el reconocimiento no demuestra que sepas palpar o aislar una contracción. Evita deducir una lesión nerviosa por un único movimiento doloroso.

### Repaso activo

Explica los conceptos sin mirar. En el cuestionario, justifica la respuesta y el error de las alternativas. Si hay cálculos, escribe fórmula, unidades y resultado. Anota las dudas y revísalas en otra sesión.

Entrenamiento original complementario al plan docente UVic 2026–2027; no son exámenes ni preguntas oficiales. La práctica clínica y las destrezas manuales requieren supervisión docente.') THEN RAISE EXCEPTION 'Rollback editorial conflict'; END IF;IF NOT EXISTS(SELECT 1 FROM public.curriculum_lessons WHERE id='f7301030-2026-4000-8002-000000000031' AND content='### Objetivos

Ordenar grupos musculares y relacionar sus acciones con marcha, rodilla y tobillo sin atribuir una tarea completa a un solo músculo.

### Muslo

El cuádriceps comprende recto femoral y vastos lateral, medial e intermedio; todos participan en extensión de rodilla. El recto femoral también cruza cadera. Los isquiotibiales incluyen semitendinoso, semimembranoso y bíceps femoral; la cabeza corta del bíceps no cruza la cadera. La región medial del muslo contiene aductores.

### Pierna y tendones

El tibial anterior participa en dorsiflexión e inversión. Gastrocnemio y sóleo contribuyen a flexión plantar mediante el tendón calcáneo; gastrocnemio también cruza rodilla. Los fibulares contribuyen a eversión. El complejo tendinoso transmite fuerza; no produce por sí solo potenciales de acción ni contracción activa.

### Orientación y función

| Grupo o estructura | Acción o relación de estudio |
|---|---|
| Cuádriceps | Extensión de rodilla |
| Recto femoral | Cruza rodilla y cadera |
| Isquiotibiales | Flexión de rodilla, con diferencias entre componentes |
| Tibial anterior | Dorsiflexión e inversión |
| Gastrocnemio y sóleo | Flexión plantar |
| Fibulares | Eversión |

El pie combina músculos extrínsecos e intrínsecos. Los tendones hacia dedos y arcos no se comprenden como piezas aisladas de la marcha. Revisa figuras enlazadas y explica qué articulaciones cruza cada músculo antes de memorizar una acción. La palpación y valoración de fuerza necesitan práctica supervisada.

### Repaso activo

Explica los conceptos sin mirar. En el cuestionario, justifica la respuesta y el error de las alternativas. Si hay cálculos, escribe fórmula, unidades y resultado. Anota las dudas y revísalas en otra sesión.

Entrenamiento original complementario al plan docente UVic 2026–2027; no son exámenes ni preguntas oficiales. La práctica clínica y las destrezas manuales requieren supervisión docente.') THEN RAISE EXCEPTION 'Rollback editorial conflict'; END IF;END $$;
COMMIT;
