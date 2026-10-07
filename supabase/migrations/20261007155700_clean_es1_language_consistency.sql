-- Clean accidental French fragments from Spanish-only ES1 lessons.
-- Explicitly bilingual FR/ES lessons are intentionally left unchanged.

update public.curriculum_lessons set content=
'Las ayudas técnicas para caminar se utilizan para mejorar la seguridad y compensar limitaciones de dolor, debilidad o equilibrio. Caminador corresponde a déambulateur y muletas a béquilles.

Durante la marcha con una ayuda técnica, MedlinePlus insiste en mirar hacia adelante y en comprobar los puntos de apoyo. La progresión debe adaptarse a la pierna más débil y a la capacidad funcional de la persona.

En una situación práctica, antes de avanzar se observa si el paciente controla el equilibrio, si puede cargar peso con seguridad y si necesita apoyo adicional. El objetivo no es solo desplazarse, sino hacerlo de forma estable y comprensible para el paciente.

### Seguridad y progresión
La elección entre caminador y muletas depende de la necesidad de estabilidad, de la capacidad de apoyo y del control del equilibrio. Antes de avanzar, se comprueban la posición, los puntos de apoyo y la comprensión de la consigna. Durante la marcha, el profesional permanece atento a la pierna más débil y a cualquier signo de pérdida de control. La ayuda técnica solo es eficaz si se utiliza de forma estable, comprendida y adaptada a la persona.'
where id='761f702e-d8e7-41b3-9c25-040166ae5a34'::uuid;

update public.curriculum_lessons set content=
'### En pocas palabras

Conceptos básicos útiles para comprender los fenómenos físicos y el movimiento humano.

### Contenido esencial

La biofísica aborda fenómenos como temperatura, calor, electricidad, magnetismo y ondas en relación con la fisiología humana y con dispositivos utilizados en fisioterapia. La biomecánica estudia fundamentos mecánicos básicos del movimiento del cuerpo humano y sus aplicaciones en fisioterapia.

### Vocabulario y puntos clave

- temperatura
- calor
- electricidad
- magnetismo
- ondas
- movimiento humano
- aplicaciones en fisioterapia

### Para memorizar

Lee primero el contenido esencial, después repasa los términos clave y comprueba que puedes explicarlos sin mirar.

### Para razonar

La biofísica aporta conceptos para comprender fenómenos como calor, electricidad y ondas; la biomecánica permite describir fuerzas y movimiento humano. En fisioterapia, estos conceptos se relacionan con la observación del movimiento y con el uso seguro de técnicas y dispositivos, sin separar la física del contexto clínico.'
where id='6803719b-72af-4e57-b5f8-ccc0d19cc480'::uuid;

update public.curriculum_lessons set content=
'La cadera es una articulación de carga que participa en la transferencia de fuerzas entre el tronco y el miembro inferior. En la valoración básica conviene relacionar movilidad, dolor, capacidad de soportar peso y patrón de marcha. El dolor originado en la propia articulación de la cadera suele percibirse con frecuencia en la ingle, aunque también puede existir dolor referido desde la espalda u otras estructuras. La marcha es una tarea funcional compleja: exige movilidad suficiente, control postural, fuerza y coordinación. Una cojera o una dificultad para subir escaleras puede orientar hacia una alteración de la función y debe contextualizarse con la historia clínica. En primer curso, el objetivo no es diagnosticar por un único signo, sino aprender a integrar anatomía, función y observación del movimiento.

En observación funcional es útil comparar apoyo, longitud del paso, estabilidad y dolor durante la marcha. Si una limitación de cadera modifica la estrategia, pueden aparecer compensaciones a nivel del tronco o de la rodilla. El razonamiento de primer curso consiste en describir estas adaptaciones y relacionarlas con la función, sin establecer un diagnóstico a partir de un dato aislado.'
where id='0c06a0f6-3fe5-4e77-b966-85493d85b7a7'::uuid;

update public.curriculum_lessons set content=
'La entrevista clínica permite comprender el dolor y su impacto funcional antes de orientar la evaluación. Preguntas como «¿Dónde siente el dolor?», «¿Desde cuándo?» o «¿Cómo es el dolor?» ayudan a caracterizar la queja principal.

También es importante preguntar qué empeora o alivia los síntomas y cómo afectan a la vida diaria. En problemas musculoesqueléticos, puede ser útil conocer si la persona puede caminar, apoyar peso o realizar sus actividades habituales.

El objetivo aquí es dominar expresiones clínicas sencillas en español y relacionarlas con su sentido funcional, sin convertirlas por sí solas en un diagnóstico.

### Estructurar la entrevista
Una secuencia simple consiste en localizar el dolor, precisar desde cuándo está presente, describir su carácter, identificar lo que lo aumenta o disminuye y medir su impacto sobre las actividades. Las preguntas sobre marcha, apoyo y vida diaria permiten relacionar síntoma y función. La reformulación final comprueba que el profesional ha entendido correctamente el mensaje del paciente antes de continuar la evaluación.'
where id='171f9491-0efc-4cd2-8a81-910f2a5829f9'::uuid;

update public.curriculum_lessons set content=
'Los nervios periféricos transmiten señales entre el sistema nervioso central y el resto del cuerpo. Según MedlinePlus, una neuropatía periférica puede producir hormigueo, ardor, entumecimiento, pérdida de sensibilidad, debilidad y dificultades para controlar los músculos o caminar. En ES1, el objetivo es reconocer estos términos y comprender su impacto funcional, sin establecer un diagnóstico.

Hormigueo, entumecimiento y debilidad son síntomas que pueden aparecer cuando existe afectación de nervios periféricos. En una anamnesis básica conviene precisar distribución, inicio, evolución y repercusión sobre la fuerza o la función. La presencia de estos síntomas exige describirlos con precisión y, si son nuevos o progresivos, comunicarlos adecuadamente al responsable clínico.

Para describir estos síntomas con precisión conviene diferenciar sensibilidad alterada, parestesias y pérdida de fuerza. También se observa si afectan a tareas como caminar, agarrar objetos o mantener una postura. La combinación de localización, evolución y repercusión funcional mejora la transmisión clínica y evita conclusiones prematuras.'
where id='5a698884-b9a3-446d-aca5-f3194689bbc9'::uuid;

select public.refresh_release_health_status_v1();
