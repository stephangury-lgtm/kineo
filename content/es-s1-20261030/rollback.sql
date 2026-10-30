BEGIN;
UPDATE public.curriculum_quiz_questions SET is_published=false,updated_at=now() WHERE metadata->>'content_batch'='es-s1-20261030';
UPDATE public.curriculum_lessons SET title='Fisiología I: bases del funcionamiento normal',summary='Introduction aux bases moléculaires, cellulaires et aux fonctions des systèmes.',content='### En pocas palabras

Introduction aux bases moléculaires, cellulaires et aux fonctions des systèmes.

### Contenido esencial

Fisiología I introduce la estructura y el funcionamiento normal del cuerpo humano. La asignatura busca relacionar las bases moleculares y fisiológicas de células y tejidos con las funciones de los diferentes aparatos y sistemas, utilizando correctamente la terminología médica.

### Vocabulario y puntos clave

- bases moleculares y fisiológicas
- células y tejidos
- funciones de aparatos y sistemas
- terminología médica

### Para memorizar

Lee primero el contenido esencial, después repasa los términos clave y comprueba que puedes explicarlos sin mirar.

### Approfondissement
La fisiología estudia cómo funcionan normalmente las células, los tejidos y los sistemas. Comprender estos mecanismos permite interpretar después los cambios que aparecen con el ejercicio, la enfermedad o la lesión. En primer curso, es importante construir vínculos entre nivel celular, tejido y función global, utilizando una terminología médica precisa.',key_points='["bases moleculares y fisiológicas","células y tejidos","funciones de aparatos y sistemas","terminología médica"]'::jsonb,source_files='[{"url":"https://kineo.stephangury.workers.dev/document/7a63b9fc-3dca-53e4-9db1-8a94ceb276fc","label":"PDF de repaso · Fisiología I: funciones del organismo — revisión externa pendiente","title":"PDF de repaso · Fisiología I: funciones del organismo — revisión externa pendiente"},{"url":"https://www.uvic.cat/assignatura/4405","label":"UVic-UCC — Fisiologia I 2026-2027"}]'::jsonb,updated_at=now() WHERE id='21afcaf4-82c8-4ea6-8778-dd0ee108ec6b' AND content='### Objetivos de repaso
Explicar por qué una membrana selecciona qué sustancias la atraviesan y comparar los mecanismos básicos de transporte. Este bloque desarrolla la fisiología celular incluida en Fisiología I; no resume por sí solo toda la asignatura.

### Estructura de la membrana
La membrana plasmática delimita el interior celular. Está formada principalmente por una bicapa de fosfolípidos con proteínas y colesterol. Las cabezas hidrófilas se orientan hacia los medios acuosos; las colas hidrófobas quedan enfrentadas hacia el interior de la bicapa. La membrana es dinámica, no una pared rígida.

### Permeabilidad selectiva
Moléculas pequeñas no polares como oxígeno y dióxido de carbono pueden atravesar la bicapa. Los iones y muchas sustancias hidrosolubles requieren proteínas para cruzarla. Un canal crea una vía selectiva; un transportador se une a una sustancia y cambia de conformación. No todas las sustancias utilizan el mismo mecanismo.

### Transporte pasivo
No exige gasto directo de energía celular para impulsar el transporte. La difusión simple desplaza partículas a favor de su gradiente de concentración. La difusión facilitada también es pasiva, aunque utilice proteínas: «usa proteína» no significa «usa ATP».
La ósmosis es el movimiento neto de agua a través de una membrana selectivamente permeable. En condiciones comparables, el agua se desplaza hacia el lado con mayor concentración de solutos que no pueden atravesar la membrana.

### Transporte activo
Requiere energía y puede mover sustancias en contra de su gradiente. En el transporte activo primario la proteína utiliza ATP directamente. En el secundario, el movimiento de una sustancia aprovecha el gradiente de otra; la energía procede indirectamente de un gradiente mantenido por mecanismos activos.

### Aplicación razonada
Si un soluto cruza mediante una proteína a favor de su gradiente sin aporte energético directo, puede ser difusión facilitada. Para clasificar un transporte pregunta: ¿qué se mueve?, ¿en qué dirección respecto al gradiente?, ¿qué proteína interviene?, ¿de dónde procede la energía?

### Errores frecuentes
Ósmosis describe agua, no cualquier soluto. Difusión facilitada no es sinónimo de transporte activo. Un gradiente es una diferencia, no una estructura.

### Autoevaluación
Compara difusión simple, difusión facilitada y transporte activo con los criterios anteriores.

Material de entrenamiento original basado en fuentes; no es un examen oficial.';
UPDATE public.curriculum_lessons SET title='Anatomía I: organización del cuerpo y sistemas',summary='Repères fondamentaux d’anatomie générale et vocabulaire des grands systèmes.',content='### En pocas palabras

Repères fondamentaux d’anatomie générale et vocabulaire des grands systèmes.

### Contenido esencial

Anatomía I aborda la organización del cuerpo humano, los procesos vitales, las cavidades corporales, la terminología anatómica básica, la célula, los tejidos, la embriología y los aparatos cardiovascular, linfático, respiratorio, urinario, digestivo y genital.

### Vocabulario y puntos clave

- organización del cuerpo humano
- terminología anatómica básica
- célula y tejidos
- embriología
- aparato cardiovascular
- aparato respiratorio
- aparato urinario
- aparato digestivo
- aparato genital

### Para memorizar

Lee primero el contenido esencial, después repasa los términos clave y comprueba que puedes explicarlos sin mirar.

Estos sistemas no se estudian de forma aislada: la anatomía general proporciona el lenguaje necesario para ubicar estructuras y comprender relaciones entre tejidos, cavidades y aparatos. Dominar la terminología básica facilita después la fisiología, la exploración y la comunicación clínica.',key_points='["organización del cuerpo humano","terminología anatómica básica","célula y tejidos","embriología","aparato cardiovascular","aparato respiratorio","aparato urinario","aparato digestivo","aparato genital"]'::jsonb,source_files='[{"url":"https://kineo.stephangury.workers.dev/document/e0272115-0d7b-56b2-99b1-20e809f71baa","label":"PDF de repaso · Anatomía I: organización y sistemas — revisión externa pendiente","title":"PDF de repaso · Anatomía I: organización y sistemas — revisión externa pendiente"},{"url":"https://www.uvic.cat/assignatura/4402","label":"UVic-UCC — Anatomia I"}]'::jsonb,updated_at=now() WHERE id='502486f5-ff65-4a23-82fe-40d4408de8d1' AND content='### Objetivos de repaso
Distinguir célula, tejido y órgano; reconocer las funciones generales de los cuatro tejidos básicos; diferenciar una membrana celular de una membrana tisular.

### De la célula al órgano
Las células son unidades vivas que se especializan. Un tejido es una agrupación organizada de células y material extracelular que participa en funciones relacionadas. Un órgano combina varios tejidos: nombrar un órgano no equivale a identificar un único tejido. La histología estudia los tejidos al microscopio.

### Los cuatro tejidos básicos
El epitelial recubre superficies, reviste cavidades y forma glándulas. El conectivo sostiene, une y protege; su matriz extracelular tiene un papel destacado. El muscular produce fuerza mediante la contracción: comprende músculo esquelético, cardíaco y liso. El nervioso permite la comunicación mediante señales electroquímicas. Clasifica por estructura y función, sin suponer que un órgano contiene un solo tipo.

### Membranas tisulares
Las mucosas revisten vías que comunican con el exterior, como el tubo digestivo. Las serosas revisten cavidades internas cerradas y recubren órganos; ayudan a reducir el rozamiento. Pleura, pericardio y peritoneo son ejemplos de serosas. La membrana cutánea es la piel. Las membranas sinoviales son membranas de tejido conectivo relacionadas con articulaciones móviles. Estas láminas de tejidos son distintas de la membrana plasmática de una célula.

### Primeras bases de embriología
Las tres capas germinales son ectodermo, mesodermo y endodermo. El tejido nervioso deriva principalmente del ectodermo; el muscular, del mesodermo. El epitelio puede tener origen en las tres capas, según su localización: «todo epitelio procede del ectodermo» es una simplificación incorrecta.

### Aplicación y errores frecuentes
En una pared de un órgano pueden coexistir revestimiento epitelial, soporte conectivo, músculo y estructuras nerviosas. Identificar el tejido exige precisar qué componente se observa.
No confundas membrana plasmática con mucosa, ni tejido muscular con órgano completo.

### Autoevaluación
Explica qué diferencia un tejido de un órgano y compara mucosa, serosa y sinovial con un ejemplo de cada una.

Material de repaso original basado en las fuentes enlazadas; no es una reproducción del curso ni un examen oficial.';
UPDATE public.curriculum_lessons SET title='Profesión y deontología',summary='Concept, champs d’action et valeurs professionnelles.',content='La fisioterapia es una profesión sanitaria con responsabilidades clínicas, éticas y de comunicación. El acto fisioterapéutico comprende la valoración, la toma de decisiones y la intervención dentro del ámbito profesional.\n\nLa deontología reúne principios que orientan la conducta profesional. El consentimiento informado implica que la persona recibe información comprensible y participa en las decisiones relacionadas con su atención.\n\nEn la práctica, el fisioterapeuta debe reconocer los límites de su actuación, respetar la autonomía de la persona y adaptar su comunicación al contexto asistencial.

### Aplicación práctica
En una situación de atención, la conducta profesional combina competencia técnica, comunicación comprensible y respeto por la decisión de la persona. Antes de intervenir, conviene explicar qué se propone, comprobar que la información se ha entendido y adaptar el lenguaje al contexto. Si la situación supera el ámbito de actuación o requiere otra competencia, reconocer ese límite forma parte de una práctica segura. Así, valoración, decisión, consentimiento y comunicación no son elementos separados: forman parte del mismo acto fisioterapéutico.',key_points='["concepto de fisioterapia","acto fisioterapéutico","deontología","consentimiento informado","ámbitos de actuación"]'::jsonb,source_files='[{"url":"https://kineo.stephangury.workers.dev/document/6f87a5e7-0448-5f1d-a3cd-5d289d40f7ff","label":"PDF de repaso · Profesión, deontología y modelos de intervención — revisión externa pendiente","title":"PDF de repaso · Profesión, deontología y modelos de intervención — revisión externa pendiente"},{"url":"https://www.uvic.cat/assignatura/4412","label":"UVic-UCC — Fonaments de la Fisioteràpia 2026-2027"}]'::jsonb,updated_at=now() WHERE id='ab7d1b48-00b2-45f3-97ae-c055c7a6a0e0' AND content='### Objetivos de repaso
Comprender el proceso de atención en fisioterapia, justificar una intervención y reconocer los factores personales y del entorno. Este repaso desarrolla competencias del programa; no sustituye los bloques de historia y técnicas de la asignatura.

### Un proceso de atención razonado
La historia clínica organiza información sobre el motivo de consulta, la evolución y las dificultades que experimenta la persona. La entrevista y la exploración aportan información que se analiza conjuntamente. El diagnóstico de fisioterapia se fundamenta en la valoración y el razonamiento clínico, e identifica problemas relevantes para el funcionamiento.

### Del diagnóstico al plan
La intervención se construye considerando la valoración, la evidencia científica disponible, las aportaciones de otros profesionales y la participación del paciente. Los objetivos deben responder a las necesidades de esa persona. Aplicar una técnica sin relacionarla con un problema identificado impide justificar su elección y valorar su utilidad.

### Funcionamiento y contexto
La recuperación no depende solamente de una estructura corporal. Los factores psicosociales y ambientales también pueden influir. Una barrera arquitectónica puede dificultar que una persona participe en una actividad aunque su capacidad física mejore. El enfoque biopsicosocial obliga a recoger información sobre la persona y su entorno, sin atribuir automáticamente sus dificultades a una única causa.

### Reevaluación y equipo
El plan requiere seguimiento. Comparar los resultados con la valoración inicial y dialogar con el paciente permite reajustarlo. Trabajar de forma interdisciplinar exige coordinar información relevante y reconocer las competencias de cada profesional. Si la situación supera las propias competencias, se solicita ayuda adecuada.

### Responsabilidad y comunicación
La conducta profesional incluye respeto por la intimidad, confidencialidad y trato equitativo. El consentimiento informado requiere información comprensible y participación en las decisiones. Una firma aislada no reemplaza la comunicación. El registro debe ser pertinente para la atención y transmitirse por canales adecuados.

### Caso de aplicación
Una persona mejora en una prueba física, pero sigue sin poder acceder a su vivienda por las escaleras. La reevaluación debe considerar esa dificultad concreta y el entorno, además de la prueba. La mejoría de una medida no demuestra por sí sola que se hayan alcanzado todos los objetivos.

### Autoevaluación
Explica cómo se conectan valoración, diagnóstico, objetivos, intervención y reevaluación. Propón un factor del entorno que pueda modificar el plan.

Ejercicios originales de entrenamiento; no son preguntas de examen autenticadas.';
UPDATE public.curriculum_lessons SET is_published=false,updated_at=now() WHERE id IN ('b7301030-2026-4000-8002-000000000001','b7301030-2026-4000-8002-000000000002');
UPDATE public.curriculum_topics SET is_active=false WHERE id IN ('b7301030-2026-4000-8001-000000000001','b7301030-2026-4000-8001-000000000002');
UPDATE public.curriculum_units SET is_active=false WHERE id IN ('b7301030-2026-4000-8000-000000000001','b7301030-2026-4000-8000-000000000002');
COMMIT;
