BEGIN;
INSERT INTO public.curriculum_topics (id,unit_id,name,slug,description,display_order,content_language,translation_mode,is_active) VALUES ('c7301030-2026-4000-8001-000000000001','74391565-393f-4f70-9286-1e1fef911959','S1 · Homeostasis y retroalimentación','s1-homeo-suite-20261030','Identifica variable regulada, receptor, centro de control y efector; compara retroalimentación negativa y positiva.',-20,'es','none',true) ON CONFLICT(id) DO NOTHING;
INSERT INTO public.curriculum_topics (id,unit_id,name,slug,description,display_order,content_language,translation_mode,is_active) VALUES ('c7301030-2026-4000-8001-000000000002','4d8d5242-af85-47fd-91ce-b8920b832b34','S1 · Corazón: cavidades, válvulas y circuitos','s1-heart-suite-20261030','Reconstruye el recorrido de la sangre y distingue arteria y vena por la dirección del flujo.',-19,'es','none',true) ON CONFLICT(id) DO NOTHING;
INSERT INTO public.curriculum_topics (id,unit_id,name,slug,description,display_order,content_language,translation_mode,is_active) VALUES ('c7301030-2026-4000-8001-000000000003','4d8d5242-af85-47fd-91ce-b8920b832b34','S1 · Aparato respiratorio: conducción y zona de intercambio','s1-resp-suite-20261030','Sigue el recorrido del aire y relaciona epitelio, cilios y alvéolos con sus funciones.',-18,'es','none',true) ON CONFLICT(id) DO NOTHING;
INSERT INTO public.curriculum_topics (id,unit_id,name,slug,description,display_order,content_language,translation_mode,is_active) VALUES ('c7301030-2026-4000-8001-000000000004','74391565-393f-4f70-9286-1e1fef911959','S1 · Sangre: componentes, transporte y protección','s1-blood-suite-20261030','Relaciona plasma, eritrocitos, leucocitos y plaquetas con sus funciones sin confundir sangre total, plasma y suero.',-17,'es','none',true) ON CONFLICT(id) DO NOTHING;
INSERT INTO public.curriculum_topics (id,unit_id,name,slug,description,display_order,content_language,translation_mode,is_active) VALUES ('c7301030-2026-4000-8001-000000000005','44f1d0a4-b8ea-4627-baef-53c0349f6d4f','S1 · CIF: función, actividad, participación y entorno','s1-cif-suite-20261030','Clasifica hallazgos funcionales y diferencia lo que una persona puede hacer de lo que hace en su contexto.',-16,'es','none',true) ON CONFLICT(id) DO NOTHING;
INSERT INTO public.curriculum_topics (id,unit_id,name,slug,description,display_order,content_language,translation_mode,is_active) VALUES ('c7301030-2026-4000-8001-000000000006','b7301030-2026-4000-8000-000000000001','S1 · Comunicación: comprensión y decisiones compartidas','s1-com-suite-20261030','Practica explicaciones claras, comprobación de la comprensión y participación de la persona en el plan.',-15,'es','none',true) ON CONFLICT(id) DO NOTHING;
INSERT INTO public.curriculum_lessons (id,topic_id,title,summary,content,key_points,source_files,display_order,validation_status,is_published) VALUES ('c7301030-2026-4000-8002-000000000001','c7301030-2026-4000-8001-000000000001','S1 · Homeostasis y retroalimentación','Identifica variable regulada, receptor, centro de control y efector; compara retroalimentación negativa y positiva.','### Lo que debes comprender

La homeostasis mantiene condiciones internas dentro de un intervalo compatible con el funcionamiento del organismo. No significa ausencia de cambios: las variables fluctúan y se regulan continuamente. El punto de ajuste sirve como referencia, pero no obliga a que una variable tenga un valor idéntico en todo momento.

### Un circuito de regulación

El receptor o sensor detecta una variable. El centro de control compara la información con la referencia y organiza una respuesta. El efector ejecuta el cambio. Para entender un ejemplo, separa qué se mide, quién interpreta la señal y quién actúa. Una misma estructura puede reunir más de una función; el esquema es funcional.

### Retroalimentación negativa

La respuesta contrarresta la desviación inicial. Si aumenta la temperatura corporal, las respuestas que facilitan la pérdida de calor contribuyen a limitar ese aumento. La vasodilatación cutánea favorece la transferencia de calor hacia la superficie; la evaporación del sudor permite perder calor. Ante el frío, el temblor muscular produce calor.
Negativa no significa perjudicial: describe la dirección de la respuesta respecto al cambio inicial.

### Retroalimentación positiva

La respuesta amplifica el cambio inicial. En el parto, el estiramiento cervical favorece la liberación de oxitocina, que aumenta las contracciones y el estiramiento. El nacimiento interrumpe el circuito. Es un proceso con un final definido; no es el mecanismo general para estabilizar todas las variables.

### Aprende a razonar

Un aumento inicial seguido de una respuesta que reduce ese aumento indica retroalimentación negativa. Si la respuesta intensifica el proceso inicial, piensa en positiva. El nombre no informa por sí solo de si un proceso es saludable o patológico.

### Errores frecuentes

Confundir efector con sensor; definir homeostasis como inmovilidad; interpretar positivo como beneficioso y negativo como dañino.

### Cómo comprobarlo

Cierra la ficha, explica los puntos clave con tus palabras y responde al cuestionario. Para cada error, identifica el concepto confundido y vuelve a la explicación antes de repetir.

Material original de entrenamiento basado en las fuentes enlazadas. No es un examen ni un apunte oficial de UVic.','["Homeostasis: estabilidad dinámica.","Sensor detecta; centro compara; efector actúa.","Negativa contrarresta una desviación.","Positiva amplifica un proceso.","El parto es un ejemplo con un final definido."]'::jsonb,'[{"url":"https://www.uvic.cat/es/assignatura/4405","label":"UVic-UCC · alcance curricular","verified_at":"2026-10-30"},{"url":"https://openstax.org/books/anatomy-and-physiology-2e/pages/1-5-homeostasis","label":"OpenStax · texto académico abierto","verified_at":"2026-10-30"}]'::jsonb,1,'source_validated',true) ON CONFLICT(id) DO NOTHING;
INSERT INTO public.curriculum_lessons (id,topic_id,title,summary,content,key_points,source_files,display_order,validation_status,is_published) VALUES ('c7301030-2026-4000-8002-000000000002','c7301030-2026-4000-8001-000000000002','S1 · Corazón: cavidades, válvulas y circuitos','Reconstruye el recorrido de la sangre y distingue arteria y vena por la dirección del flujo.','### Objetivo

Poder seguir una gota de sangre a través de los circuitos pulmonar y sistémico, identificando cavidades y válvulas sin depender de colores de un dibujo.

### Localización y cavidades

El corazón está en el mediastino, entre los pulmones. Tiene dos aurículas y dos ventrículos. Las aurículas reciben sangre; los ventrículos la impulsan hacia los circuitos. El miocardio es la capa muscular de la pared cardíaca. El pericardio envuelve el corazón.

### Recorrido completo

La sangre de la circulación sistémica regresa por las venas cavas a la aurícula derecha. Pasa por la válvula tricúspide al ventrículo derecho, atraviesa la válvula pulmonar y sale por el tronco pulmonar hacia los pulmones.
Tras el intercambio pulmonar, vuelve por las venas pulmonares a la aurícula izquierda. Cruza la válvula mitral o bicúspide hacia el ventrículo izquierdo y sale, a través de la válvula aórtica, hacia la aorta y la circulación sistémica.

### Arterias y venas

Una arteria conduce sangre desde el corazón; una vena la devuelve hacia él. El criterio es la dirección, no la cantidad de oxígeno. En la circulación pulmonar del adulto, las arterias llevan sangre relativamente pobre en oxígeno y las venas sangre rica en oxígeno. Por eso no conviene memorizar «arteria equivale a sangre oxigenada».

### Válvulas y pared

Las válvulas favorecen el flujo unidireccional y evitan el retroceso. Tricúspide y mitral son auriculoventriculares; pulmonar y aórtica son semilunares. El ventrículo izquierdo tiene una pared muscular más gruesa porque impulsa sangre al circuito sistémico, que requiere mayor presión.

### Práctica sin mirar

Recita el recorrido desde las cavas hasta la aorta e identifica dónde cambian los contenidos de oxígeno y dióxido de carbono. En un esquema, comprueba si la derecha corresponde al paciente o a quien observa.

### Cómo comprobarlo

Cierra la ficha, explica los puntos clave con tus palabras y responde al cuestionario. Para cada error, identifica el concepto confundido y vuelve a la explicación antes de repetir.

Material original de entrenamiento basado en las fuentes enlazadas. No es un examen ni un apunte oficial de UVic.','["Aurículas reciben; ventrículos impulsan.","Derecho → pulmones; izquierdo → sistema.","Tricúspide derecha; mitral izquierda.","Arteria sale del corazón; vena vuelve.","Las válvulas limitan el retroceso."]'::jsonb,'[{"url":"https://www.uvic.cat/es/assignatura/4402","label":"UVic-UCC · alcance curricular","verified_at":"2026-10-30"},{"url":"https://openstax.org/books/anatomy-and-physiology-2e/pages/19-1-heart-anatomy","label":"OpenStax · texto académico abierto","verified_at":"2026-10-30"}]'::jsonb,1,'source_validated',true) ON CONFLICT(id) DO NOTHING;
INSERT INTO public.curriculum_lessons (id,topic_id,title,summary,content,key_points,source_files,display_order,validation_status,is_published) VALUES ('c7301030-2026-4000-8002-000000000003','c7301030-2026-4000-8001-000000000003','S1 · Aparato respiratorio: conducción y zona de intercambio','Sigue el recorrido del aire y relaciona epitelio, cilios y alvéolos con sus funciones.','### Objetivo

Separar las estructuras que conducen el aire de las que participan directamente en el intercambio gaseoso.

### Recorrido del aire

Desde las cavidades nasales, el aire pasa por faringe, laringe, tráquea, bronquios y bronquiolos. Los bronquiolos terminales pertenecen a la zona de conducción. Después aparecen bronquiolos respiratorios, conductos alveolares y alvéolos, que forman parte de la zona respiratoria.

### Zona de conducción

Proporciona una vía de entrada y salida del aire y contribuye a filtrarlo, calentarlo y humidificarlo. La tráquea no es el principal lugar de intercambio de oxígeno con la sangre.
En buena parte de las vías de conducción, el moco atrapa partículas y los cilios contribuyen a transportarlo hacia la faringe. Moco y cilios cumplen funciones complementarias: uno retiene material y los otros lo movilizan. Los cilios no producen por sí solos el moco.

### Faringe y laringe

La faringe tiene porciones nasofaríngea, orofaríngea y laringofaríngea. La orofaringe es una vía compartida por aire y alimentos. La laringe conecta la faringe con la tráquea y participa en la producción de la voz. No debe confundirse con el esófago, que pertenece a la vía digestiva.

### Alvéolos

Los alvéolos ofrecen una superficie especializada para el intercambio con los capilares. Los neumocitos de tipo I, delgados, participan en la barrera de intercambio. Los de tipo II producen surfactante, que reduce la tensión superficial. Los macrófagos alveolares participan en la defensa mediante fagocitosis.
Ventilar es mover aire; intercambiar gases es transferirlos entre aire alveolar y sangre. Son procesos relacionados, pero diferentes.

### Caso para razonar

Si una pregunta sitúa el intercambio gaseoso en la tráquea, identifica el error de localización antes de responder. Para explicar una función, vincula siempre estructura y tarea.

### Errores frecuentes

Confundir bronquiolo terminal con respiratorio; atribuir el moco a los cilios; confundir ventilación con intercambio.

### Cómo comprobarlo

Cierra la ficha, explica los puntos clave con tus palabras y responde al cuestionario. Para cada error, identifica el concepto confundido y vuelve a la explicación antes de repetir.

Material original de entrenamiento basado en las fuentes enlazadas. No es un examen ni un apunte oficial de UVic.','["Conducción: transporte y acondicionamiento del aire.","Zona respiratoria: intercambio gaseoso.","Moco atrapa; cilios movilizan.","Tipo I: barrera; tipo II: surfactante.","Ventilar no equivale a intercambiar gases."]'::jsonb,'[{"url":"https://www.uvic.cat/es/assignatura/4402","label":"UVic-UCC · alcance curricular","verified_at":"2026-10-30"},{"url":"https://openstax.org/books/anatomy-and-physiology-2e/pages/22-1-organs-and-structures-of-the-respiratory-system","label":"OpenStax · texto académico abierto","verified_at":"2026-10-30"}]'::jsonb,1,'source_validated',true) ON CONFLICT(id) DO NOTHING;
INSERT INTO public.curriculum_lessons (id,topic_id,title,summary,content,key_points,source_files,display_order,validation_status,is_published) VALUES ('c7301030-2026-4000-8002-000000000004','c7301030-2026-4000-8001-000000000004','S1 · Sangre: componentes, transporte y protección','Relaciona plasma, eritrocitos, leucocitos y plaquetas con sus funciones sin confundir sangre total, plasma y suero.','### Objetivo

Distinguir los componentes de la sangre y justificar su función. Este bloque es introductorio: los grupos sanguíneos, la hematopoyesis y la cascada de coagulación requieren estudio adicional.

### Un tejido conectivo líquido

La sangre incluye elementos formes suspendidos en una matriz extracelular líquida: el plasma. Los elementos formes son eritrocitos, leucocitos y plaquetas; estas últimas son fragmentos celulares, no células completas equivalentes a los leucocitos.

### Transporte y defensa

La sangre transporta gases, nutrientes, hormonas y productos de desecho. Los eritrocitos contienen hemoglobina, relacionada con el transporte de oxígeno. Los leucocitos participan en la defensa; no deben confundirse con plaquetas. Las plaquetas y proteínas plasmáticas colaboran en la hemostasia para limitar la pérdida de sangre tras una lesión vascular.

### Plasma y proteínas

El plasma está compuesto principalmente por agua con proteínas y otros solutos. La albúmina contribuye a la presión osmótica plasmática y transporta determinadas sustancias. Las inmunoglobulinas participan en la inmunidad. El fibrinógeno interviene en la coagulación.
El suero es el líquido obtenido después de la coagulación y carece de fibrinógeno funcional disponible como en el plasma. No es equivalente a sangre total.

### Hematocrito

Expresa la fracción del volumen sanguíneo ocupada por eritrocitos. No indica la proporción de leucocitos ni es el mismo dato que la concentración de hemoglobina. En una muestra centrifugada, los eritrocitos se sitúan abajo, el plasma arriba y una capa fina intermedia contiene leucocitos y plaquetas.

### Homeostasis

La sangre contribuye a distribuir calor, regular el equilibrio químico y transportar sustancias entre órganos. Una misma función global puede depender de varios componentes: hemostasia no significa «solo plaquetas» e inmunidad no significa «solo un tipo de célula».

### Errores frecuentes

Llamar plasma a toda la sangre; confundir plaquetas con leucocitos; interpretar hematocrito como porcentaje de hemoglobina.

### Cómo comprobarlo

Cierra la ficha y explica los puntos clave con tus palabras. Responde al cuestionario y, en cada error, identifica qué concepto has confundido antes de repetir.

Material original de entrenamiento basado en las fuentes enlazadas; no es un examen oficial de UVic.','["Plasma: matriz líquida de la sangre.","Eritrocitos: transporte de oxígeno mediante hemoglobina.","Leucocitos: defensa; plaquetas: hemostasia.","Albúmina, inmunoglobulinas y fibrinógeno tienen funciones distintas.","Hematocrito: volumen ocupado por eritrocitos."]'::jsonb,'[{"url":"https://www.uvic.cat/es/assignatura/4405","label":"UVic-UCC · alcance curricular","verified_at":"2026-10-30"},{"url":"https://openstax.org/books/anatomy-and-physiology-2e/pages/18-1-an-overview-of-blood","label":"OpenStax · texto académico abierto","verified_at":"2026-10-30"}]'::jsonb,1,'source_validated',true) ON CONFLICT(id) DO NOTHING;
INSERT INTO public.curriculum_lessons (id,topic_id,title,summary,content,key_points,source_files,display_order,validation_status,is_published) VALUES ('c7301030-2026-4000-8002-000000000005','c7301030-2026-4000-8001-000000000005','S1 · CIF: función, actividad, participación y entorno','Clasifica hallazgos funcionales y diferencia lo que una persona puede hacer de lo que hace en su contexto.','### Objetivo

Utilizar la CIF como lenguaje para describir funcionamiento y discapacidad sin reducir la valoración a un diagnóstico médico.

### Componentes básicos

Las funciones corporales son las funciones fisiológicas de los sistemas, incluidas las psicológicas. Las estructuras corporales son partes anatómicas, como órganos y miembros. Una deficiencia es un problema significativo de función o estructura.
Actividad significa ejecutar una tarea o acción. Participación significa implicarse en una situación de la vida. Dificultad para realizar una tarea es limitación de actividad; un problema para implicarse en una situación vital es restricción de participación. En casos reales, actividad y participación están relacionadas y su distinción exige explicar qué aspecto se describe.

### Capacidad y desempeño

El desempeño describe lo que la persona hace en su entorno actual. La capacidad valora la aptitud para ejecutar una tarea en un entorno uniforme o estandarizado. Deben especificarse las condiciones y las ayudas: una prueba en consulta no describe automáticamente toda la vida diaria.
Si alguien camina en un pasillo accesible, pero no puede llegar a su vivienda por escaleras, hay que investigar esa diferencia y el contexto.

### Factores ambientales

El entorno físico, social y actitudinal puede facilitar o dificultar el funcionamiento. Una rampa, una ayuda técnica o apoyo de otras personas pueden facilitar una actividad. Escaleras inaccesibles o actitudes discriminatorias pueden actuar como barreras. Un mismo elemento puede tener efectos diferentes según la persona y la situación.

### Análisis paso a paso

En un caso separa: qué función o estructura está afectada, qué tarea presenta dificultades, qué situación vital importa a la persona y qué factores del entorno intervienen. No deduzcas automáticamente un grado de discapacidad a partir del nombre de una enfermedad.

### Ejemplo

Una persona presenta dolor, dificultad para caminar y ausencia del trabajo por problemas para acceder al edificio. Dolor, marcha y participación laboral son dimensiones diferentes; el acceso al edificio aporta información ambiental. Registrar solo dolor deja una parte importante sin describir.

### Errores frecuentes

Confundir actividad con estructura; omitir funciones psicológicas; suponer que diagnóstico y funcionamiento son equivalentes.

### Cómo comprobarlo

Cierra la ficha y explica los puntos clave con tus palabras. Responde al cuestionario y, en cada error, identifica qué concepto has confundido antes de repetir.

Material original de entrenamiento basado en las fuentes enlazadas; no es un examen oficial de UVic.','["La CIF incluye funciones psicológicas.","Estructura: parte anatómica; función: proceso fisiológico.","Actividad: tarea; participación: situación de vida.","Desempeño: entorno actual; capacidad: condiciones estandarizadas.","El entorno puede ser barrera o facilitador."]'::jsonb,'[{"url":"https://www.uvic.cat/es/assignatura/4412","label":"UVic-UCC · alcance curricular","verified_at":"2026-10-30"},{"url":"https://www.who.int/docs/default-source/classification/icf/icfchecklist.pdf","label":"OMS · ICF Checklist","verified_at":"2026-10-30"},{"url":"https://cdn.who.int/media/docs/default-source/classification/icf/drafticfpracticalmanual2.pdf","label":"OMS · Manuel pratique CIF · projet de 2013 · capacité et performance","verified_at":"2026-10-30"}]'::jsonb,1,'source_validated',true) ON CONFLICT(id) DO NOTHING;
INSERT INTO public.curriculum_lessons (id,topic_id,title,summary,content,key_points,source_files,display_order,validation_status,is_published) VALUES ('c7301030-2026-4000-8002-000000000006','c7301030-2026-4000-8001-000000000006','S1 · Comunicación: comprensión y decisiones compartidas','Practica explicaciones claras, comprobación de la comprensión y participación de la persona en el plan.','### Objetivo

Convertir una explicación técnica en una conversación que permita comprender opciones y decidir con la persona.

### Antes de explicar

Explora qué le importa, qué espera y qué preguntas desea resolver. Al inicio, acordad los asuntos prioritarios y el tiempo disponible. La información debe adaptarse al contexto y a las necesidades de accesibilidad. No se presupone que todas las personas quieran o puedan participar de la misma manera.

### Información por partes

Presenta pequeñas unidades de información y comprueba la comprensión antes de avanzar. Explicar muchas instrucciones seguidas puede dificultar saber qué se ha entendido.
La comprobación mediante reformulación, o teach-back, consiste en invitar a explicar con palabras propias lo tratado. Evalúa la claridad de la explicación, no el valor ni la inteligencia de la persona. «¿Ha entendido?» puede obtener un sí sin mostrar qué se ha comprendido.

### Opciones y preferencias

Comenta objetivos, beneficios, riesgos y consecuencias de las opciones pertinentes. La conversación también puede incluir no cambiar el tratamiento o no intervenir, según la situación. Las preferencias del profesional no sustituyen a las del paciente. Hay que reconocer incertidumbres y dejar tiempo para preguntas.
Una ayuda de decisión apoya la conversación; no la reemplaza ni debe imponer una opción.

### Apoyos

Pregunta si la persona desea implicar a familiares, amistades o personas de apoyo. Su presencia no se da por supuesta. Cuando existen dificultades para comprender o participar, se puede valorar apoyo adicional, por ejemplo interpretación o formatos accesibles.

### Cierre y seguimiento

Resume qué se ha acordado, qué ocurrirá después y cuándo se revisará. Registra las decisiones y los aspectos importantes para la persona. Explica cómo plantear nuevas dudas y que la decisión puede revisarse.

### Simulación de práctica

En parejas, una persona explica dos opciones y la otra reformula lo entendido. Quien explica identifica qué debe aclarar y ambos acuerdan el siguiente paso.

Estas recomendaciones se usan como referencia de comunicación clínica; NICE es una fuente británica, no una norma jurídica española.

### Cómo comprobarlo

Cierra la ficha y explica los puntos clave con tus palabras. Responde al cuestionario y, en cada error, identifica qué concepto has confundido antes de repetir.

Material original de entrenamiento basado en las fuentes enlazadas; no es un examen oficial de UVic.','["Preguntar qué importa a la persona.","Explicar por partes y comprobar comprensión.","Teach-back: reformular, no examinar.","Discutir opciones, riesgos y preferencias.","Cerrar con plan y revisión acordados."]'::jsonb,'[{"url":"https://www.uvic.cat/es/assignatura/4409","label":"UVic-UCC · alcance curricular","verified_at":"2026-10-30"},{"url":"https://www.nice.org.uk/guidance/ng197/chapter/Recommendations","label":"NICE NG197 · recomendaciones 1.2","verified_at":"2026-10-30"}]'::jsonb,1,'source_validated',true) ON CONFLICT(id) DO NOTHING;
INSERT INTO public.curriculum_lessons (id,topic_id,title,summary,content,key_points,source_files,display_order,validation_status,is_published) VALUES ('c7301030-2026-4000-8002-000000000007','b7301030-2026-4000-8001-000000000001','Guía de estudio · Cómo usar las fichas y aprender de los errores','Una rutina flexible con recuerdo activo, práctica espaciada y revisión razonada de errores.','### Una sesión posible

Esta distribución es una propuesta práctica, no una duración óptima demostrada para todos.
- Elige un bloque y revisa sus objetivos.
- Lee la ficha y relaciona cada concepto con un ejemplo.
- Cierra el texto e intenta explicarlo sin mirar.
- Haz el cuestionario antes de consultar la corrección.
- Comprueba por qué la opción correcta lo es y por qué tu elección falla.
- Anota una regla breve o una comparación que evite repetir el error.

### Repasar en varios días

Distribuye las sesiones en el tiempo en lugar de concentrar todo el estudio en una sola jornada. Como ejemplo adaptable, vuelve al bloque al día siguiente, unos días después y la semana siguiente. Estos intervalos son una propuesta organizativa, no una configuración automática de la aplicación.

### Tres categorías para tus errores

- No lo sabía: vuelve al concepto y crea una pregunta breve.
- Confundí dos ideas: escribe la diferencia y un ejemplo de cada una.
- Leí mal: identifica la palabra que cambió el sentido y relee todas las opciones.

### Responder bien no siempre significa dominar

Tras acertar, intenta justificar la respuesta sin mirar. Reconocer una frase no equivale siempre a poder recuperarla y explicarla. Revisa los fallos con mayor frecuencia, pero vuelve también a contenidos ya acertados.

### Un orden orientativo

Empieza por organización y tejidos; después membrana y transporte, homeostasis, sangre, corazón y aparato respiratorio. Alterna con CIF, fundamentos, psicología y cultura. Es una propuesta de recorrido por los bloques disponibles; no reemplaza el calendario docente ni significa que todo el semestre esté cubierto.

### Cuidar el entorno de estudio

Reduce interrupciones y evita estudiar con varias fuentes de distracción a la vez. Reserva descanso suficiente: el sueño participa en la consolidación de la memoria. Una regla mnemotécnica puede ayudar a recordar una lista, pero comprueba que también entiendes su significado.

### Antes de una evaluación

Usa el programa del profesor para comprobar qué falta. Estas fichas y preguntas son material complementario de entrenamiento, no exámenes oficiales ni una predicción del examen.','["Explicar sin mirar.","Distribuir las sesiones.","Revisar las causas de cada error.","Relacionar ideas con ejemplos.","Usar el programa docente como lista de comprobación."]'::jsonb,'[{"url":"https://openstax.org/books/psychology-2e/pages/8-4-ways-to-enhance-memory","label":"OpenStax Psychology 2e · Ways to Enhance Memory","verified_at":"2026-10-30"}]'::jsonb,0,'source_validated',true) ON CONFLICT(id) DO NOTHING;
INSERT INTO public.curriculum_quiz_questions (id,topic_id,question_text,explanation,options,difficulty,source_label,display_order,question_type,metadata,validation_status,is_published) VALUES ('c7301030-2026-4000-8003-000000000001','c7301030-2026-4000-8001-000000000001','En un circuito homeostático, ¿qué función corresponde al receptor?','El receptor o sensor monitoriza una variable e informa al centro de control.','[{"text":"Detectar cambios en la variable regulada","correct":true},{"text":"Ejecutar siempre la contracción muscular","correct":false},{"text":"Producir necesariamente la respuesta hormonal","correct":false},{"text":"Fijar por sí solo todos los valores normales","correct":false}]'::jsonb,1,'Entrenamiento original · https://openstax.org/books/anatomy-and-physiology-2e/pages/1-5-homeostasis',1,'mcq','{"content_batch":"es-s1-suite-20261030","academic_semester":1,"academic_year":1,"language":"es","origin":"original_training","external_expert_review":"pending","source_urls":["https://openstax.org/books/anatomy-and-physiology-2e/pages/1-5-homeostasis"],"verified_at":"2026-10-30"}'::jsonb,'source_validated',true) ON CONFLICT(id) DO NOTHING;
INSERT INTO public.curriculum_quiz_questions (id,topic_id,question_text,explanation,options,difficulty,source_label,display_order,question_type,metadata,validation_status,is_published) VALUES ('c7301030-2026-4000-8003-000000000002','c7301030-2026-4000-8001-000000000001','¿Qué hace el centro de control en un esquema de retroalimentación?','El centro de control interpreta la desviación y organiza la activación de efectores.','[{"text":"Actúa exclusivamente como barrera física","correct":false},{"text":"Sustituye a todos los efectores","correct":false},{"text":"Impide cualquier variación fisiológica","correct":false},{"text":"Compara la información recibida con la referencia y coordina la respuesta","correct":true}]'::jsonb,1,'Entrenamiento original · https://openstax.org/books/anatomy-and-physiology-2e/pages/1-5-homeostasis',2,'mcq','{"content_batch":"es-s1-suite-20261030","academic_semester":1,"academic_year":1,"language":"es","origin":"original_training","external_expert_review":"pending","source_urls":["https://openstax.org/books/anatomy-and-physiology-2e/pages/1-5-homeostasis"],"verified_at":"2026-10-30"}'::jsonb,'source_validated',true) ON CONFLICT(id) DO NOTHING;
INSERT INTO public.curriculum_quiz_questions (id,topic_id,question_text,explanation,options,difficulty,source_label,display_order,question_type,metadata,validation_status,is_published) VALUES ('c7301030-2026-4000-8003-000000000003','c7301030-2026-4000-8001-000000000001','¿Qué expresión caracteriza mejor la homeostasis?','Las variables fluctúan y los mecanismos reguladores contribuyen a mantenerlas en rangos funcionales.','[{"text":"Ausencia de intercambio con el medio","correct":false},{"text":"Aumento continuo de todas las variables","correct":false},{"text":"Mantenimiento dinámico de condiciones internas dentro de un intervalo","correct":true},{"text":"Conservación exacta e invariable de toda medida","correct":false}]'::jsonb,1,'Entrenamiento original · https://openstax.org/books/anatomy-and-physiology-2e/pages/1-5-homeostasis',3,'mcq','{"content_batch":"es-s1-suite-20261030","academic_semester":1,"academic_year":1,"language":"es","origin":"original_training","external_expert_review":"pending","source_urls":["https://openstax.org/books/anatomy-and-physiology-2e/pages/1-5-homeostasis"],"verified_at":"2026-10-30"}'::jsonb,'source_validated',true) ON CONFLICT(id) DO NOTHING;
INSERT INTO public.curriculum_quiz_questions (id,topic_id,question_text,explanation,options,difficulty,source_label,display_order,question_type,metadata,validation_status,is_published) VALUES ('c7301030-2026-4000-8003-000000000004','c7301030-2026-4000-8001-000000000001','La temperatura aumenta y una respuesta facilita perder calor. ¿Qué tipo de retroalimentación representa?','La respuesta se opone al aumento inicial de temperatura.','[{"text":"Amplificación sin límite","correct":false},{"text":"Negativa","correct":true},{"text":"Positiva","correct":false},{"text":"Ausencia de regulación","correct":false}]'::jsonb,2,'Entrenamiento original · https://openstax.org/books/anatomy-and-physiology-2e/pages/1-5-homeostasis',4,'clinical_case','{"content_batch":"es-s1-suite-20261030","academic_semester":1,"academic_year":1,"language":"es","origin":"original_training","external_expert_review":"pending","source_urls":["https://openstax.org/books/anatomy-and-physiology-2e/pages/1-5-homeostasis"],"verified_at":"2026-10-30"}'::jsonb,'source_validated',true) ON CONFLICT(id) DO NOTHING;
INSERT INTO public.curriculum_quiz_questions (id,topic_id,question_text,explanation,options,difficulty,source_label,display_order,question_type,metadata,validation_status,is_published) VALUES ('c7301030-2026-4000-8003-000000000005','c7301030-2026-4000-8001-000000000001','¿Qué estructura actúa como efector al secretar sudor?','La glándula ejecuta una respuesta que contribuye a la pérdida de calor.','[{"text":"La glándula sudorípara","correct":true},{"text":"El estímulo térmico","correct":false},{"text":"El valor de referencia","correct":false},{"text":"La información detectada","correct":false}]'::jsonb,1,'Entrenamiento original · https://openstax.org/books/anatomy-and-physiology-2e/pages/1-5-homeostasis',5,'mcq','{"content_batch":"es-s1-suite-20261030","academic_semester":1,"academic_year":1,"language":"es","origin":"original_training","external_expert_review":"pending","source_urls":["https://openstax.org/books/anatomy-and-physiology-2e/pages/1-5-homeostasis"],"verified_at":"2026-10-30"}'::jsonb,'source_validated',true) ON CONFLICT(id) DO NOTHING;
INSERT INTO public.curriculum_quiz_questions (id,topic_id,question_text,explanation,options,difficulty,source_label,display_order,question_type,metadata,validation_status,is_published) VALUES ('c7301030-2026-4000-8003-000000000006','c7301030-2026-4000-8001-000000000001','¿Cómo contribuye el temblor ante el frío a la regulación térmica?','Las contracciones musculares del temblor liberan calor.','[{"text":"La actividad muscular detiene todo uso de ATP","correct":false},{"text":"El temblor aumenta la evaporación como única vía","correct":false},{"text":"El temblor elimina el centro de control","correct":false},{"text":"La actividad muscular genera calor","correct":true}]'::jsonb,1,'Entrenamiento original · https://openstax.org/books/anatomy-and-physiology-2e/pages/1-5-homeostasis',6,'mcq','{"content_batch":"es-s1-suite-20261030","academic_semester":1,"academic_year":1,"language":"es","origin":"original_training","external_expert_review":"pending","source_urls":["https://openstax.org/books/anatomy-and-physiology-2e/pages/1-5-homeostasis"],"verified_at":"2026-10-30"}'::jsonb,'source_validated',true) ON CONFLICT(id) DO NOTHING;
INSERT INTO public.curriculum_quiz_questions (id,topic_id,question_text,explanation,options,difficulty,source_label,display_order,question_type,metadata,validation_status,is_published) VALUES ('c7301030-2026-4000-8003-000000000007','c7301030-2026-4000-8001-000000000001','¿Qué proceso explica la pérdida de calor asociada al sudor?','Al evaporarse, el agua transporta calor desde la superficie hacia el entorno.','[{"text":"La síntesis de colágeno cutáneo","correct":false},{"text":"La interrupción de la circulación pulmonar","correct":false},{"text":"Su evaporación desde la superficie corporal","correct":true},{"text":"Su acumulación sin evaporarse como única condición","correct":false}]'::jsonb,1,'Entrenamiento original · https://openstax.org/books/anatomy-and-physiology-2e/pages/1-5-homeostasis',7,'mcq','{"content_batch":"es-s1-suite-20261030","academic_semester":1,"academic_year":1,"language":"es","origin":"original_training","external_expert_review":"pending","source_urls":["https://openstax.org/books/anatomy-and-physiology-2e/pages/1-5-homeostasis"],"verified_at":"2026-10-30"}'::jsonb,'source_validated',true) ON CONFLICT(id) DO NOTHING;
INSERT INTO public.curriculum_quiz_questions (id,topic_id,question_text,explanation,options,difficulty,source_label,display_order,question_type,metadata,validation_status,is_published) VALUES ('c7301030-2026-4000-8003-000000000008','c7301030-2026-4000-8001-000000000001','Durante el parto, el estiramiento cervical favorece contracciones que aumentan el estiramiento. ¿Cómo se clasifica ese circuito?','La respuesta refuerza el proceso inicial; el nacimiento pone fin al circuito.','[{"text":"Regulación sin respuesta efectora","correct":false},{"text":"Retroalimentación positiva","correct":true},{"text":"Retroalimentación negativa","correct":false},{"text":"Difusión facilitada","correct":false}]'::jsonb,2,'Entrenamiento original · https://openstax.org/books/anatomy-and-physiology-2e/pages/1-5-homeostasis',8,'clinical_case','{"content_batch":"es-s1-suite-20261030","academic_semester":1,"academic_year":1,"language":"es","origin":"original_training","external_expert_review":"pending","source_urls":["https://openstax.org/books/anatomy-and-physiology-2e/pages/1-5-homeostasis"],"verified_at":"2026-10-30"}'::jsonb,'source_validated',true) ON CONFLICT(id) DO NOTHING;
INSERT INTO public.curriculum_quiz_questions (id,topic_id,question_text,explanation,options,difficulty,source_label,display_order,question_type,metadata,validation_status,is_published) VALUES ('c7301030-2026-4000-8003-000000000009','c7301030-2026-4000-8001-000000000001','¿Qué significa negativa en retroalimentación negativa?','Negativa describe oposición al cambio inicial; una respuesta puede aumentar una variable que había descendido.','[{"text":"Que la respuesta contrarresta la desviación inicial","correct":true},{"text":"Que el mecanismo siempre causa daño","correct":false},{"text":"Que el efector nunca se activa","correct":false},{"text":"Que la variable solo puede disminuir","correct":false}]'::jsonb,1,'Entrenamiento original · https://openstax.org/books/anatomy-and-physiology-2e/pages/1-5-homeostasis',9,'mcq','{"content_batch":"es-s1-suite-20261030","academic_semester":1,"academic_year":1,"language":"es","origin":"original_training","external_expert_review":"pending","source_urls":["https://openstax.org/books/anatomy-and-physiology-2e/pages/1-5-homeostasis"],"verified_at":"2026-10-30"}'::jsonb,'source_validated',true) ON CONFLICT(id) DO NOTHING;
INSERT INTO public.curriculum_quiz_questions (id,topic_id,question_text,explanation,options,difficulty,source_label,display_order,question_type,metadata,validation_status,is_published) VALUES ('c7301030-2026-4000-8003-000000000010','c7301030-2026-4000-8001-000000000001','Una variable desciende y la respuesta contribuye a elevarla hacia su referencia. ¿Qué mecanismo describe?','La respuesta corrige la desviación, aunque para ello eleve la variable.','[{"text":"Retroalimentación positiva porque el valor aumenta","correct":false},{"text":"Ausencia de sensor por definición","correct":false},{"text":"Amplificación obligatoria del descenso","correct":false},{"text":"Retroalimentación negativa","correct":true}]'::jsonb,2,'Entrenamiento original · https://openstax.org/books/anatomy-and-physiology-2e/pages/1-5-homeostasis',10,'clinical_case','{"content_batch":"es-s1-suite-20261030","academic_semester":1,"academic_year":1,"language":"es","origin":"original_training","external_expert_review":"pending","source_urls":["https://openstax.org/books/anatomy-and-physiology-2e/pages/1-5-homeostasis"],"verified_at":"2026-10-30"}'::jsonb,'source_validated',true) ON CONFLICT(id) DO NOTHING;
INSERT INTO public.curriculum_quiz_questions (id,topic_id,question_text,explanation,options,difficulty,source_label,display_order,question_type,metadata,validation_status,is_published) VALUES ('c7301030-2026-4000-8003-000000000011','c7301030-2026-4000-8001-000000000002','¿En qué espacio se sitúa el corazón?','El corazón se localiza en el mediastino, entre ambos pulmones.','[{"text":"Mediastino","correct":true},{"text":"Cavidad pleural derecha","correct":false},{"text":"Cavidad peritoneal","correct":false},{"text":"Canal vertebral","correct":false}]'::jsonb,1,'Entrenamiento original · https://openstax.org/books/anatomy-and-physiology-2e/pages/19-1-heart-anatomy',1,'mcq','{"content_batch":"es-s1-suite-20261030","academic_semester":1,"academic_year":1,"language":"es","origin":"original_training","external_expert_review":"pending","source_urls":["https://openstax.org/books/anatomy-and-physiology-2e/pages/19-1-heart-anatomy"],"verified_at":"2026-10-30"}'::jsonb,'source_validated',true) ON CONFLICT(id) DO NOTHING;
INSERT INTO public.curriculum_quiz_questions (id,topic_id,question_text,explanation,options,difficulty,source_label,display_order,question_type,metadata,validation_status,is_published) VALUES ('c7301030-2026-4000-8003-000000000012','c7301030-2026-4000-8001-000000000002','La sangre de las venas cavas entra primero en:','Las venas cavas desembocan en la aurícula derecha.','[{"text":"La aurícula izquierda","correct":false},{"text":"El ventrículo izquierdo","correct":false},{"text":"El tronco pulmonar","correct":false},{"text":"La aurícula derecha","correct":true}]'::jsonb,1,'Entrenamiento original · https://openstax.org/books/anatomy-and-physiology-2e/pages/19-1-heart-anatomy',2,'mcq','{"content_batch":"es-s1-suite-20261030","academic_semester":1,"academic_year":1,"language":"es","origin":"original_training","external_expert_review":"pending","source_urls":["https://openstax.org/books/anatomy-and-physiology-2e/pages/19-1-heart-anatomy"],"verified_at":"2026-10-30"}'::jsonb,'source_validated',true) ON CONFLICT(id) DO NOTHING;
INSERT INTO public.curriculum_quiz_questions (id,topic_id,question_text,explanation,options,difficulty,source_label,display_order,question_type,metadata,validation_status,is_published) VALUES ('c7301030-2026-4000-8003-000000000013','c7301030-2026-4000-8001-000000000002','¿Qué válvula comunica aurícula derecha y ventrículo derecho?','La tricúspide es la válvula auriculoventricular derecha.','[{"text":"Aórtica","correct":false},{"text":"Pulmonar","correct":false},{"text":"Tricúspide","correct":true},{"text":"Mitral","correct":false}]'::jsonb,1,'Entrenamiento original · https://openstax.org/books/anatomy-and-physiology-2e/pages/19-1-heart-anatomy',3,'mcq','{"content_batch":"es-s1-suite-20261030","academic_semester":1,"academic_year":1,"language":"es","origin":"original_training","external_expert_review":"pending","source_urls":["https://openstax.org/books/anatomy-and-physiology-2e/pages/19-1-heart-anatomy"],"verified_at":"2026-10-30"}'::jsonb,'source_validated',true) ON CONFLICT(id) DO NOTHING;
INSERT INTO public.curriculum_quiz_questions (id,topic_id,question_text,explanation,options,difficulty,source_label,display_order,question_type,metadata,validation_status,is_published) VALUES ('c7301030-2026-4000-8003-000000000014','c7301030-2026-4000-8001-000000000002','¿Qué cavidad impulsa la sangre hacia el tronco pulmonar?','El ventrículo derecho eyecta sangre al tronco pulmonar a través de la válvula pulmonar.','[{"text":"Aurícula izquierda","correct":false},{"text":"Ventrículo derecho","correct":true},{"text":"Aurícula derecha","correct":false},{"text":"Ventrículo izquierdo","correct":false}]'::jsonb,1,'Entrenamiento original · https://openstax.org/books/anatomy-and-physiology-2e/pages/19-1-heart-anatomy',4,'mcq','{"content_batch":"es-s1-suite-20261030","academic_semester":1,"academic_year":1,"language":"es","origin":"original_training","external_expert_review":"pending","source_urls":["https://openstax.org/books/anatomy-and-physiology-2e/pages/19-1-heart-anatomy"],"verified_at":"2026-10-30"}'::jsonb,'source_validated',true) ON CONFLICT(id) DO NOTHING;
INSERT INTO public.curriculum_quiz_questions (id,topic_id,question_text,explanation,options,difficulty,source_label,display_order,question_type,metadata,validation_status,is_published) VALUES ('c7301030-2026-4000-8003-000000000015','c7301030-2026-4000-8001-000000000002','¿A qué cavidad llega la sangre de las venas pulmonares?','Las venas pulmonares devuelven la sangre de los pulmones a la aurícula izquierda.','[{"text":"Aurícula izquierda","correct":true},{"text":"Aurícula derecha","correct":false},{"text":"Ventrículo derecho","correct":false},{"text":"Ventrículo izquierdo directamente","correct":false}]'::jsonb,1,'Entrenamiento original · https://openstax.org/books/anatomy-and-physiology-2e/pages/19-1-heart-anatomy',5,'mcq','{"content_batch":"es-s1-suite-20261030","academic_semester":1,"academic_year":1,"language":"es","origin":"original_training","external_expert_review":"pending","source_urls":["https://openstax.org/books/anatomy-and-physiology-2e/pages/19-1-heart-anatomy"],"verified_at":"2026-10-30"}'::jsonb,'source_validated',true) ON CONFLICT(id) DO NOTHING;
INSERT INTO public.curriculum_quiz_questions (id,topic_id,question_text,explanation,options,difficulty,source_label,display_order,question_type,metadata,validation_status,is_published) VALUES ('c7301030-2026-4000-8003-000000000016','c7301030-2026-4000-8001-000000000002','¿Cuál es otro nombre de la válvula mitral?','La válvula mitral o bicúspide se encuentra entre aurícula y ventrículo izquierdos.','[{"text":"Tricúspide","correct":false},{"text":"Pulmonar","correct":false},{"text":"Aórtica","correct":false},{"text":"Bicúspide","correct":true}]'::jsonb,1,'Entrenamiento original · https://openstax.org/books/anatomy-and-physiology-2e/pages/19-1-heart-anatomy',6,'mcq','{"content_batch":"es-s1-suite-20261030","academic_semester":1,"academic_year":1,"language":"es","origin":"original_training","external_expert_review":"pending","source_urls":["https://openstax.org/books/anatomy-and-physiology-2e/pages/19-1-heart-anatomy"],"verified_at":"2026-10-30"}'::jsonb,'source_validated',true) ON CONFLICT(id) DO NOTHING;
INSERT INTO public.curriculum_quiz_questions (id,topic_id,question_text,explanation,options,difficulty,source_label,display_order,question_type,metadata,validation_status,is_published) VALUES ('c7301030-2026-4000-8003-000000000017','c7301030-2026-4000-8001-000000000002','¿Qué cavidad comunica con la aorta a través de la válvula aórtica?','El ventrículo izquierdo impulsa sangre hacia la circulación sistémica por la aorta.','[{"text":"Aurícula derecha","correct":false},{"text":"Aurícula izquierda","correct":false},{"text":"Ventrículo izquierdo","correct":true},{"text":"Ventrículo derecho","correct":false}]'::jsonb,1,'Entrenamiento original · https://openstax.org/books/anatomy-and-physiology-2e/pages/19-1-heart-anatomy',7,'mcq','{"content_batch":"es-s1-suite-20261030","academic_semester":1,"academic_year":1,"language":"es","origin":"original_training","external_expert_review":"pending","source_urls":["https://openstax.org/books/anatomy-and-physiology-2e/pages/19-1-heart-anatomy"],"verified_at":"2026-10-30"}'::jsonb,'source_validated',true) ON CONFLICT(id) DO NOTHING;
INSERT INTO public.curriculum_quiz_questions (id,topic_id,question_text,explanation,options,difficulty,source_label,display_order,question_type,metadata,validation_status,is_published) VALUES ('c7301030-2026-4000-8003-000000000018','c7301030-2026-4000-8001-000000000002','Un estudiante afirma que las arterias pulmonares deben llevar sangre rica en oxígeno porque son arterias. ¿Qué criterio corrige el error?','La dirección respecto al corazón define arteria y vena; el contenido de oxígeno depende del circuito.','[{"text":"El nombre depende únicamente del diámetro","correct":false},{"text":"Una arteria se define por conducir sangre desde el corazón","correct":true},{"text":"Una arteria se define por llegar a una aurícula","correct":false},{"text":"Una vena se define por carecer de oxígeno","correct":false}]'::jsonb,2,'Entrenamiento original · https://openstax.org/books/anatomy-and-physiology-2e/pages/19-1-heart-anatomy',8,'clinical_case','{"content_batch":"es-s1-suite-20261030","academic_semester":1,"academic_year":1,"language":"es","origin":"original_training","external_expert_review":"pending","source_urls":["https://openstax.org/books/anatomy-and-physiology-2e/pages/19-1-heart-anatomy"],"verified_at":"2026-10-30"}'::jsonb,'source_validated',true) ON CONFLICT(id) DO NOTHING;
INSERT INTO public.curriculum_quiz_questions (id,topic_id,question_text,explanation,options,difficulty,source_label,display_order,question_type,metadata,validation_status,is_published) VALUES ('c7301030-2026-4000-8003-000000000019','c7301030-2026-4000-8001-000000000002','¿Cuál es una función principal de las válvulas cardíacas?','Las válvulas favorecen el flujo en una dirección al impedir el retroceso.','[{"text":"Limitar el retroceso de la sangre","correct":true},{"text":"Producir eritrocitos","correct":false},{"text":"Intercambiar gases con el aire","correct":false},{"text":"Originar por sí solas toda la contracción","correct":false}]'::jsonb,1,'Entrenamiento original · https://openstax.org/books/anatomy-and-physiology-2e/pages/19-1-heart-anatomy',9,'mcq','{"content_batch":"es-s1-suite-20261030","academic_semester":1,"academic_year":1,"language":"es","origin":"original_training","external_expert_review":"pending","source_urls":["https://openstax.org/books/anatomy-and-physiology-2e/pages/19-1-heart-anatomy"],"verified_at":"2026-10-30"}'::jsonb,'source_validated',true) ON CONFLICT(id) DO NOTHING;
INSERT INTO public.curriculum_quiz_questions (id,topic_id,question_text,explanation,options,difficulty,source_label,display_order,question_type,metadata,validation_status,is_published) VALUES ('c7301030-2026-4000-8003-000000000020','c7301030-2026-4000-8001-000000000002','¿Qué pareja de válvulas es semilunar?','Las semilunares están en las salidas de los ventrículos; mitral y tricúspide son auriculoventriculares.','[{"text":"Mitral y tricúspide","correct":false},{"text":"Mitral y aórtica","correct":false},{"text":"Tricúspide y pulmonar","correct":false},{"text":"Aórtica y pulmonar","correct":true}]'::jsonb,1,'Entrenamiento original · https://openstax.org/books/anatomy-and-physiology-2e/pages/19-1-heart-anatomy',10,'mcq','{"content_batch":"es-s1-suite-20261030","academic_semester":1,"academic_year":1,"language":"es","origin":"original_training","external_expert_review":"pending","source_urls":["https://openstax.org/books/anatomy-and-physiology-2e/pages/19-1-heart-anatomy"],"verified_at":"2026-10-30"}'::jsonb,'source_validated',true) ON CONFLICT(id) DO NOTHING;
INSERT INTO public.curriculum_quiz_questions (id,topic_id,question_text,explanation,options,difficulty,source_label,display_order,question_type,metadata,validation_status,is_published) VALUES ('c7301030-2026-4000-8003-000000000021','c7301030-2026-4000-8001-000000000003','¿Qué estructura pertenece a la zona de conducción?','La zona de conducción llega a los bronquiolos terminales; los respiratorios participan en la zona de intercambio.','[{"text":"Bronquiolo terminal","correct":true},{"text":"Alvéolo","correct":false},{"text":"Conducto alveolar","correct":false},{"text":"Bronquiolo respiratorio","correct":false}]'::jsonb,1,'Entrenamiento original · https://openstax.org/books/anatomy-and-physiology-2e/pages/22-1-organs-and-structures-of-the-respiratory-system',1,'mcq','{"content_batch":"es-s1-suite-20261030","academic_semester":1,"academic_year":1,"language":"es","origin":"original_training","external_expert_review":"pending","source_urls":["https://openstax.org/books/anatomy-and-physiology-2e/pages/22-1-organs-and-structures-of-the-respiratory-system"],"verified_at":"2026-10-30"}'::jsonb,'source_validated',true) ON CONFLICT(id) DO NOTHING;
INSERT INTO public.curriculum_quiz_questions (id,topic_id,question_text,explanation,options,difficulty,source_label,display_order,question_type,metadata,validation_status,is_published) VALUES ('c7301030-2026-4000-8003-000000000022','c7301030-2026-4000-8001-000000000003','¿Qué conjunto pertenece a la zona respiratoria?','La zona respiratoria contiene estructuras especializadas en el intercambio gaseoso.','[{"text":"Faringe, laringe y tráquea","correct":false},{"text":"Cavidad nasal, esófago y tráquea","correct":false},{"text":"Bronquios principales y cavidad nasal exclusivamente","correct":false},{"text":"Bronquiolos respiratorios, conductos alveolares y alvéolos","correct":true}]'::jsonb,1,'Entrenamiento original · https://openstax.org/books/anatomy-and-physiology-2e/pages/22-1-organs-and-structures-of-the-respiratory-system',2,'mcq','{"content_batch":"es-s1-suite-20261030","academic_semester":1,"academic_year":1,"language":"es","origin":"original_training","external_expert_review":"pending","source_urls":["https://openstax.org/books/anatomy-and-physiology-2e/pages/22-1-organs-and-structures-of-the-respiratory-system"],"verified_at":"2026-10-30"}'::jsonb,'source_validated',true) ON CONFLICT(id) DO NOTHING;
INSERT INTO public.curriculum_quiz_questions (id,topic_id,question_text,explanation,options,difficulty,source_label,display_order,question_type,metadata,validation_status,is_published) VALUES ('c7301030-2026-4000-8003-000000000023','c7301030-2026-4000-8001-000000000003','¿Qué función cumple principalmente el moco de las vías respiratorias?','El moco retiene partículas; los cilios ayudan a desplazarlo.','[{"text":"Formar la barrera alveolocapilar completa","correct":false},{"text":"Sustituir la circulación pulmonar","correct":false},{"text":"Atrapar partículas del aire inspirado","correct":true},{"text":"Producir la contracción ventricular","correct":false}]'::jsonb,1,'Entrenamiento original · https://openstax.org/books/anatomy-and-physiology-2e/pages/22-1-organs-and-structures-of-the-respiratory-system',3,'mcq','{"content_batch":"es-s1-suite-20261030","academic_semester":1,"academic_year":1,"language":"es","origin":"original_training","external_expert_review":"pending","source_urls":["https://openstax.org/books/anatomy-and-physiology-2e/pages/22-1-organs-and-structures-of-the-respiratory-system"],"verified_at":"2026-10-30"}'::jsonb,'source_validated',true) ON CONFLICT(id) DO NOTHING;
INSERT INTO public.curriculum_quiz_questions (id,topic_id,question_text,explanation,options,difficulty,source_label,display_order,question_type,metadata,validation_status,is_published) VALUES ('c7301030-2026-4000-8003-000000000024','c7301030-2026-4000-8001-000000000003','¿Qué función realizan los cilios en el aclaramiento de las vías de conducción?','El movimiento ciliar contribuye a movilizar el moco y el material retenido.','[{"text":"Transportar sangre hacia la aurícula izquierda","correct":false},{"text":"Desplazar el moco con partículas hacia la faringe","correct":true},{"text":"Sintetizar toda la hemoglobina","correct":false},{"text":"Secretar el surfactante alveolar","correct":false}]'::jsonb,1,'Entrenamiento original · https://openstax.org/books/anatomy-and-physiology-2e/pages/22-1-organs-and-structures-of-the-respiratory-system',4,'mcq','{"content_batch":"es-s1-suite-20261030","academic_semester":1,"academic_year":1,"language":"es","origin":"original_training","external_expert_review":"pending","source_urls":["https://openstax.org/books/anatomy-and-physiology-2e/pages/22-1-organs-and-structures-of-the-respiratory-system"],"verified_at":"2026-10-30"}'::jsonb,'source_validated',true) ON CONFLICT(id) DO NOTHING;
INSERT INTO public.curriculum_quiz_questions (id,topic_id,question_text,explanation,options,difficulty,source_label,display_order,question_type,metadata,validation_status,is_published) VALUES ('c7301030-2026-4000-8003-000000000025','c7301030-2026-4000-8001-000000000003','¿Qué porción de la faringe sirve de paso tanto para aire como para alimentos?','La orofaringe constituye una vía común para aire y alimentos.','[{"text":"Orofaringe","correct":true},{"text":"Nasofaringe exclusivamente","correct":false},{"text":"Tráquea","correct":false},{"text":"Bronquiolo terminal","correct":false}]'::jsonb,1,'Entrenamiento original · https://openstax.org/books/anatomy-and-physiology-2e/pages/22-1-organs-and-structures-of-the-respiratory-system',5,'mcq','{"content_batch":"es-s1-suite-20261030","academic_semester":1,"academic_year":1,"language":"es","origin":"original_training","external_expert_review":"pending","source_urls":["https://openstax.org/books/anatomy-and-physiology-2e/pages/22-1-organs-and-structures-of-the-respiratory-system"],"verified_at":"2026-10-30"}'::jsonb,'source_validated',true) ON CONFLICT(id) DO NOTHING;
INSERT INTO public.curriculum_quiz_questions (id,topic_id,question_text,explanation,options,difficulty,source_label,display_order,question_type,metadata,validation_status,is_published) VALUES ('c7301030-2026-4000-8003-000000000026','c7301030-2026-4000-8001-000000000003','¿Qué estructura conecta la faringe con la tráquea y participa en la voz?','La laringe está situada entre la faringe y la tráquea y alberga estructuras de la fonación.','[{"text":"Esófago","correct":false},{"text":"Alvéolo","correct":false},{"text":"Vena pulmonar","correct":false},{"text":"Laringe","correct":true}]'::jsonb,1,'Entrenamiento original · https://openstax.org/books/anatomy-and-physiology-2e/pages/22-1-organs-and-structures-of-the-respiratory-system',6,'mcq','{"content_batch":"es-s1-suite-20261030","academic_semester":1,"academic_year":1,"language":"es","origin":"original_training","external_expert_review":"pending","source_urls":["https://openstax.org/books/anatomy-and-physiology-2e/pages/22-1-organs-and-structures-of-the-respiratory-system"],"verified_at":"2026-10-30"}'::jsonb,'source_validated',true) ON CONFLICT(id) DO NOTHING;
INSERT INTO public.curriculum_quiz_questions (id,topic_id,question_text,explanation,options,difficulty,source_label,display_order,question_type,metadata,validation_status,is_published) VALUES ('c7301030-2026-4000-8003-000000000027','c7301030-2026-4000-8001-000000000003','¿Qué células alveolares forman buena parte de la superficie delgada de intercambio?','Los neumocitos de tipo I son células delgadas adaptadas al intercambio gaseoso.','[{"text":"Células caliciformes de la tráquea","correct":false},{"text":"Condrocitos","correct":false},{"text":"Neumocitos de tipo I","correct":true},{"text":"Neumocitos de tipo II exclusivamente","correct":false}]'::jsonb,1,'Entrenamiento original · https://openstax.org/books/anatomy-and-physiology-2e/pages/22-1-organs-and-structures-of-the-respiratory-system',7,'mcq','{"content_batch":"es-s1-suite-20261030","academic_semester":1,"academic_year":1,"language":"es","origin":"original_training","external_expert_review":"pending","source_urls":["https://openstax.org/books/anatomy-and-physiology-2e/pages/22-1-organs-and-structures-of-the-respiratory-system"],"verified_at":"2026-10-30"}'::jsonb,'source_validated',true) ON CONFLICT(id) DO NOTHING;
INSERT INTO public.curriculum_quiz_questions (id,topic_id,question_text,explanation,options,difficulty,source_label,display_order,question_type,metadata,validation_status,is_published) VALUES ('c7301030-2026-4000-8003-000000000028','c7301030-2026-4000-8001-000000000003','¿Qué células producen surfactante alveolar?','Los neumocitos de tipo II secretan surfactante, que reduce la tensión superficial.','[{"text":"Células ciliadas nasales","correct":false},{"text":"Neumocitos de tipo II","correct":true},{"text":"Neumocitos de tipo I","correct":false},{"text":"Eritrocitos","correct":false}]'::jsonb,1,'Entrenamiento original · https://openstax.org/books/anatomy-and-physiology-2e/pages/22-1-organs-and-structures-of-the-respiratory-system',8,'mcq','{"content_batch":"es-s1-suite-20261030","academic_semester":1,"academic_year":1,"language":"es","origin":"original_training","external_expert_review":"pending","source_urls":["https://openstax.org/books/anatomy-and-physiology-2e/pages/22-1-organs-and-structures-of-the-respiratory-system"],"verified_at":"2026-10-30"}'::jsonb,'source_validated',true) ON CONFLICT(id) DO NOTHING;
INSERT INTO public.curriculum_quiz_questions (id,topic_id,question_text,explanation,options,difficulty,source_label,display_order,question_type,metadata,validation_status,is_published) VALUES ('c7301030-2026-4000-8003-000000000029','c7301030-2026-4000-8001-000000000003','En una preparación alveolar se identifica una célula que fagocita partículas. ¿Qué célula es la más compatible?','Los macrófagos alveolares participan en la defensa eliminando partículas mediante fagocitosis.','[{"text":"Macrófago alveolar","correct":true},{"text":"Eritrocito","correct":false},{"text":"Condrocito","correct":false},{"text":"Neumocito de tipo I como función principal","correct":false}]'::jsonb,2,'Entrenamiento original · https://openstax.org/books/anatomy-and-physiology-2e/pages/22-1-organs-and-structures-of-the-respiratory-system',9,'clinical_case','{"content_batch":"es-s1-suite-20261030","academic_semester":1,"academic_year":1,"language":"es","origin":"original_training","external_expert_review":"pending","source_urls":["https://openstax.org/books/anatomy-and-physiology-2e/pages/22-1-organs-and-structures-of-the-respiratory-system"],"verified_at":"2026-10-30"}'::jsonb,'source_validated',true) ON CONFLICT(id) DO NOTHING;
INSERT INTO public.curriculum_quiz_questions (id,topic_id,question_text,explanation,options,difficulty,source_label,display_order,question_type,metadata,validation_status,is_published) VALUES ('c7301030-2026-4000-8003-000000000030','c7301030-2026-4000-8001-000000000003','Un estudiante considera que mover aire por la tráquea ya demuestra intercambio gaseoso. ¿Qué distinción necesita?','El paso de aire por una vía de conducción no equivale a la transferencia de gases a través de la superficie alveolar.','[{"text":"Ventilación e intercambio son siempre el mismo proceso","correct":false},{"text":"La tráquea realiza todo el intercambio sanguíneo","correct":false},{"text":"Los alvéolos solo transportan moco","correct":false},{"text":"Ventilación mueve aire; el intercambio transfiere gases entre alvéolos y sangre","correct":true}]'::jsonb,2,'Entrenamiento original · https://openstax.org/books/anatomy-and-physiology-2e/pages/22-1-organs-and-structures-of-the-respiratory-system',10,'clinical_case','{"content_batch":"es-s1-suite-20261030","academic_semester":1,"academic_year":1,"language":"es","origin":"original_training","external_expert_review":"pending","source_urls":["https://openstax.org/books/anatomy-and-physiology-2e/pages/22-1-organs-and-structures-of-the-respiratory-system"],"verified_at":"2026-10-30"}'::jsonb,'source_validated',true) ON CONFLICT(id) DO NOTHING;
INSERT INTO public.curriculum_quiz_questions (id,topic_id,question_text,explanation,options,difficulty,source_label,display_order,question_type,metadata,validation_status,is_published) VALUES ('c7301030-2026-4000-8003-000000000031','c7301030-2026-4000-8001-000000000004','¿Cuál es la matriz extracelular líquida de la sangre?','El plasma es la matriz líquida que mantiene suspendidos los elementos formes.','[{"text":"Plasma","correct":true},{"text":"Miocardio","correct":false},{"text":"Médula ósea","correct":false},{"text":"Membrana sinovial","correct":false}]'::jsonb,1,'Entrenamiento original · https://openstax.org/books/anatomy-and-physiology-2e/pages/18-1-an-overview-of-blood',1,'mcq','{"content_batch":"es-s1-suite-20261030","academic_semester":1,"academic_year":1,"language":"es","origin":"original_training","external_expert_review":"pending","source_urls":["https://openstax.org/books/anatomy-and-physiology-2e/pages/18-1-an-overview-of-blood"],"verified_at":"2026-10-30"}'::jsonb,'source_validated',true) ON CONFLICT(id) DO NOTHING;
INSERT INTO public.curriculum_quiz_questions (id,topic_id,question_text,explanation,options,difficulty,source_label,display_order,question_type,metadata,validation_status,is_published) VALUES ('c7301030-2026-4000-8003-000000000032','c7301030-2026-4000-8001-000000000004','¿Qué elemento forme es un fragmento celular?','Las plaquetas son fragmentos celulares; los leucocitos mencionados son células.','[{"text":"Neutrófilo","correct":false},{"text":"Linfocito","correct":false},{"text":"Monocito","correct":false},{"text":"Plaqueta","correct":true}]'::jsonb,1,'Entrenamiento original · https://openstax.org/books/anatomy-and-physiology-2e/pages/18-1-an-overview-of-blood',2,'mcq','{"content_batch":"es-s1-suite-20261030","academic_semester":1,"academic_year":1,"language":"es","origin":"original_training","external_expert_review":"pending","source_urls":["https://openstax.org/books/anatomy-and-physiology-2e/pages/18-1-an-overview-of-blood"],"verified_at":"2026-10-30"}'::jsonb,'source_validated',true) ON CONFLICT(id) DO NOTHING;
INSERT INTO public.curriculum_quiz_questions (id,topic_id,question_text,explanation,options,difficulty,source_label,display_order,question_type,metadata,validation_status,is_published) VALUES ('c7301030-2026-4000-8003-000000000033','c7301030-2026-4000-8001-000000000004','¿Qué componente está más directamente relacionado con el transporte de oxígeno mediante hemoglobina?','Los eritrocitos contienen hemoglobina, que participa en el transporte de oxígeno.','[{"text":"Linfocito","correct":false},{"text":"Fibrinógeno","correct":false},{"text":"Eritrocito","correct":true},{"text":"Plaqueta","correct":false}]'::jsonb,1,'Entrenamiento original · https://openstax.org/books/anatomy-and-physiology-2e/pages/18-1-an-overview-of-blood',3,'mcq','{"content_batch":"es-s1-suite-20261030","academic_semester":1,"academic_year":1,"language":"es","origin":"original_training","external_expert_review":"pending","source_urls":["https://openstax.org/books/anatomy-and-physiology-2e/pages/18-1-an-overview-of-blood"],"verified_at":"2026-10-30"}'::jsonb,'source_validated',true) ON CONFLICT(id) DO NOTHING;
INSERT INTO public.curriculum_quiz_questions (id,topic_id,question_text,explanation,options,difficulty,source_label,display_order,question_type,metadata,validation_status,is_published) VALUES ('c7301030-2026-4000-8003-000000000034','c7301030-2026-4000-8001-000000000004','¿Qué grupo celular participa de forma destacada en la defensa del organismo?','Los leucocitos incluyen células con funciones inmunitarias.','[{"text":"Fosfolípidos plasmáticos","correct":false},{"text":"Leucocitos","correct":true},{"text":"Eritrocitos","correct":false},{"text":"Plaquetas exclusivamente","correct":false}]'::jsonb,1,'Entrenamiento original · https://openstax.org/books/anatomy-and-physiology-2e/pages/18-1-an-overview-of-blood',4,'mcq','{"content_batch":"es-s1-suite-20261030","academic_semester":1,"academic_year":1,"language":"es","origin":"original_training","external_expert_review":"pending","source_urls":["https://openstax.org/books/anatomy-and-physiology-2e/pages/18-1-an-overview-of-blood"],"verified_at":"2026-10-30"}'::jsonb,'source_validated',true) ON CONFLICT(id) DO NOTHING;
INSERT INTO public.curriculum_quiz_questions (id,topic_id,question_text,explanation,options,difficulty,source_label,display_order,question_type,metadata,validation_status,is_published) VALUES ('c7301030-2026-4000-8003-000000000035','c7301030-2026-4000-8001-000000000004','¿Qué proteína plasmática participa de forma destacada en la coagulación?','El fibrinógeno es una proteína plasmática esencial para la coagulación.','[{"text":"Fibrinógeno","correct":true},{"text":"Albúmina","correct":false},{"text":"Hemoglobina","correct":false},{"text":"Insulina","correct":false}]'::jsonb,1,'Entrenamiento original · https://openstax.org/books/anatomy-and-physiology-2e/pages/18-1-an-overview-of-blood',5,'mcq','{"content_batch":"es-s1-suite-20261030","academic_semester":1,"academic_year":1,"language":"es","origin":"original_training","external_expert_review":"pending","source_urls":["https://openstax.org/books/anatomy-and-physiology-2e/pages/18-1-an-overview-of-blood"],"verified_at":"2026-10-30"}'::jsonb,'source_validated',true) ON CONFLICT(id) DO NOTHING;
INSERT INTO public.curriculum_quiz_questions (id,topic_id,question_text,explanation,options,difficulty,source_label,display_order,question_type,metadata,validation_status,is_published) VALUES ('c7301030-2026-4000-8003-000000000036','c7301030-2026-4000-8001-000000000004','¿Qué proteína contribuye especialmente a la presión osmótica del plasma?','La albúmina es abundante en el plasma y contribuye a retener agua en el compartimento vascular.','[{"text":"Colágeno del tendón","correct":false},{"text":"Queratina","correct":false},{"text":"Actina del sarcómero","correct":false},{"text":"Albúmina","correct":true}]'::jsonb,1,'Entrenamiento original · https://openstax.org/books/anatomy-and-physiology-2e/pages/18-1-an-overview-of-blood',6,'mcq','{"content_batch":"es-s1-suite-20261030","academic_semester":1,"academic_year":1,"language":"es","origin":"original_training","external_expert_review":"pending","source_urls":["https://openstax.org/books/anatomy-and-physiology-2e/pages/18-1-an-overview-of-blood"],"verified_at":"2026-10-30"}'::jsonb,'source_validated',true) ON CONFLICT(id) DO NOTHING;
INSERT INTO public.curriculum_quiz_questions (id,topic_id,question_text,explanation,options,difficulty,source_label,display_order,question_type,metadata,validation_status,is_published) VALUES ('c7301030-2026-4000-8003-000000000037','c7301030-2026-4000-8001-000000000004','¿Qué nombre reciben las proteínas plasmáticas relacionadas con anticuerpos?','Las inmunoglobulinas son anticuerpos relacionados con la inmunidad.','[{"text":"Colágenos","correct":false},{"text":"Queratinas","correct":false},{"text":"Inmunoglobulinas","correct":true},{"text":"Fibrinógenos","correct":false}]'::jsonb,1,'Entrenamiento original · https://openstax.org/books/anatomy-and-physiology-2e/pages/18-1-an-overview-of-blood',7,'mcq','{"content_batch":"es-s1-suite-20261030","academic_semester":1,"academic_year":1,"language":"es","origin":"original_training","external_expert_review":"pending","source_urls":["https://openstax.org/books/anatomy-and-physiology-2e/pages/18-1-an-overview-of-blood"],"verified_at":"2026-10-30"}'::jsonb,'source_validated',true) ON CONFLICT(id) DO NOTHING;
INSERT INTO public.curriculum_quiz_questions (id,topic_id,question_text,explanation,options,difficulty,source_label,display_order,question_type,metadata,validation_status,is_published) VALUES ('c7301030-2026-4000-8003-000000000038','c7301030-2026-4000-8001-000000000004','¿Qué representa el hematocrito?','El hematocrito mide el volumen relativo de eritrocitos, no la concentración de hemoglobina.','[{"text":"La proporción de oxígeno del aire inspirado","correct":false},{"text":"La fracción del volumen sanguíneo ocupada por eritrocitos","correct":true},{"text":"La fracción ocupada únicamente por leucocitos","correct":false},{"text":"La concentración de glucosa plasmática","correct":false}]'::jsonb,1,'Entrenamiento original · https://openstax.org/books/anatomy-and-physiology-2e/pages/18-1-an-overview-of-blood',8,'mcq','{"content_batch":"es-s1-suite-20261030","academic_semester":1,"academic_year":1,"language":"es","origin":"original_training","external_expert_review":"pending","source_urls":["https://openstax.org/books/anatomy-and-physiology-2e/pages/18-1-an-overview-of-blood"],"verified_at":"2026-10-30"}'::jsonb,'source_validated',true) ON CONFLICT(id) DO NOTHING;
INSERT INTO public.curriculum_quiz_questions (id,topic_id,question_text,explanation,options,difficulty,source_label,display_order,question_type,metadata,validation_status,is_published) VALUES ('c7301030-2026-4000-8003-000000000039','c7301030-2026-4000-8001-000000000004','Tras centrifugar sangre anticoagulada, ¿dónde se encuentra principalmente el plasma?','Los eritrocitos sedimentan y el plasma queda por encima; la capa intermedia contiene leucocitos y plaquetas.','[{"text":"En la capa superior","correct":true},{"text":"En el fondo bajo los eritrocitos","correct":false},{"text":"Solo dentro de los leucocitos","correct":false},{"text":"En una capa de tejido sólido","correct":false}]'::jsonb,2,'Entrenamiento original · https://openstax.org/books/anatomy-and-physiology-2e/pages/18-1-an-overview-of-blood',9,'clinical_case','{"content_batch":"es-s1-suite-20261030","academic_semester":1,"academic_year":1,"language":"es","origin":"original_training","external_expert_review":"pending","source_urls":["https://openstax.org/books/anatomy-and-physiology-2e/pages/18-1-an-overview-of-blood"],"verified_at":"2026-10-30"}'::jsonb,'source_validated',true) ON CONFLICT(id) DO NOTHING;
INSERT INTO public.curriculum_quiz_questions (id,topic_id,question_text,explanation,options,difficulty,source_label,display_order,question_type,metadata,validation_status,is_published) VALUES ('c7301030-2026-4000-8003-000000000040','c7301030-2026-4000-8001-000000000004','Un estudiante atribuye la hemostasia únicamente a las plaquetas. ¿Qué componente debe añadir?','Plaquetas y proteínas de coagulación colaboran para limitar la pérdida de sangre.','[{"text":"Solo hormonas tiroideas","correct":false},{"text":"Solo cilios respiratorios","correct":false},{"text":"Solo fibras nerviosas","correct":false},{"text":"Proteínas plasmáticas de la coagulación","correct":true}]'::jsonb,2,'Entrenamiento original · https://openstax.org/books/anatomy-and-physiology-2e/pages/18-1-an-overview-of-blood',10,'clinical_case','{"content_batch":"es-s1-suite-20261030","academic_semester":1,"academic_year":1,"language":"es","origin":"original_training","external_expert_review":"pending","source_urls":["https://openstax.org/books/anatomy-and-physiology-2e/pages/18-1-an-overview-of-blood"],"verified_at":"2026-10-30"}'::jsonb,'source_validated',true) ON CONFLICT(id) DO NOTHING;
INSERT INTO public.curriculum_quiz_questions (id,topic_id,question_text,explanation,options,difficulty,source_label,display_order,question_type,metadata,validation_status,is_published) VALUES ('c7301030-2026-4000-8003-000000000041','c7301030-2026-4000-8001-000000000005','¿Cómo se clasifica la memoria dentro de la CIF?','Las funciones corporales incluyen funciones psicológicas; la memoria es una función mental.','[{"text":"Función corporal","correct":true},{"text":"Estructura ósea","correct":false},{"text":"Producto tecnológico","correct":false},{"text":"Servicio de transporte","correct":false}]'::jsonb,1,'Entrenamiento original · https://www.who.int/docs/default-source/classification/icf/icfchecklist.pdf',1,'mcq','{"content_batch":"es-s1-suite-20261030","academic_semester":1,"academic_year":1,"language":"es","origin":"original_training","external_expert_review":"pending","source_urls":["https://www.who.int/docs/default-source/classification/icf/icfchecklist.pdf","https://cdn.who.int/media/docs/default-source/classification/icf/drafticfpracticalmanual2.pdf"],"verified_at":"2026-10-30"}'::jsonb,'source_validated',true) ON CONFLICT(id) DO NOTHING;
INSERT INTO public.curriculum_quiz_questions (id,topic_id,question_text,explanation,options,difficulty,source_label,display_order,question_type,metadata,validation_status,is_published) VALUES ('c7301030-2026-4000-8003-000000000042','c7301030-2026-4000-8001-000000000005','¿Cuál de estos datos describe una estructura corporal?','Las estructuras son partes anatómicas del cuerpo, a diferencia de tareas y factores del entorno.','[{"text":"La ejecución de vestirse","correct":false},{"text":"El apoyo de una amistad","correct":false},{"text":"El desplazamiento al trabajo","correct":false},{"text":"Un componente anatómico del miembro inferior","correct":true}]'::jsonb,1,'Entrenamiento original · https://www.who.int/docs/default-source/classification/icf/icfchecklist.pdf',2,'mcq','{"content_batch":"es-s1-suite-20261030","academic_semester":1,"academic_year":1,"language":"es","origin":"original_training","external_expert_review":"pending","source_urls":["https://www.who.int/docs/default-source/classification/icf/icfchecklist.pdf","https://cdn.who.int/media/docs/default-source/classification/icf/drafticfpracticalmanual2.pdf"],"verified_at":"2026-10-30"}'::jsonb,'source_validated',true) ON CONFLICT(id) DO NOTHING;
INSERT INTO public.curriculum_quiz_questions (id,topic_id,question_text,explanation,options,difficulty,source_label,display_order,question_type,metadata,validation_status,is_published) VALUES ('c7301030-2026-4000-8003-000000000043','c7301030-2026-4000-8001-000000000005','Si se describe la dificultad para ejecutar la tarea de ponerse una camiseta, ¿qué dimensión se está destacando?','El enunciado se centra en ejecutar una tarea concreta.','[{"text":"Protección social","correct":false},{"text":"Secreción hormonal","correct":false},{"text":"Limitación de actividad","correct":true},{"text":"Cambio de estructura por sí solo","correct":false}]'::jsonb,2,'Entrenamiento original · https://www.who.int/docs/default-source/classification/icf/icfchecklist.pdf',3,'clinical_case','{"content_batch":"es-s1-suite-20261030","academic_semester":1,"academic_year":1,"language":"es","origin":"original_training","external_expert_review":"pending","source_urls":["https://www.who.int/docs/default-source/classification/icf/icfchecklist.pdf","https://cdn.who.int/media/docs/default-source/classification/icf/drafticfpracticalmanual2.pdf"],"verified_at":"2026-10-30"}'::jsonb,'source_validated',true) ON CONFLICT(id) DO NOTHING;
INSERT INTO public.curriculum_quiz_questions (id,topic_id,question_text,explanation,options,difficulty,source_label,display_order,question_type,metadata,validation_status,is_published) VALUES ('c7301030-2026-4000-8003-000000000044','c7301030-2026-4000-8001-000000000005','Si se describe la imposibilidad de mantener la implicación en la vida laboral, ¿qué dimensión se destaca?','La participación se refiere a la implicación en situaciones de la vida, como el empleo.','[{"text":"Una membrana celular","correct":false},{"text":"Restricción de participación","correct":true},{"text":"Una estructura anatómica aislada","correct":false},{"text":"El valor de una hormona","correct":false}]'::jsonb,2,'Entrenamiento original · https://www.who.int/docs/default-source/classification/icf/icfchecklist.pdf',4,'clinical_case','{"content_batch":"es-s1-suite-20261030","academic_semester":1,"academic_year":1,"language":"es","origin":"original_training","external_expert_review":"pending","source_urls":["https://www.who.int/docs/default-source/classification/icf/icfchecklist.pdf","https://cdn.who.int/media/docs/default-source/classification/icf/drafticfpracticalmanual2.pdf"],"verified_at":"2026-10-30"}'::jsonb,'source_validated',true) ON CONFLICT(id) DO NOTHING;
INSERT INTO public.curriculum_quiz_questions (id,topic_id,question_text,explanation,options,difficulty,source_label,display_order,question_type,metadata,validation_status,is_published) VALUES ('c7301030-2026-4000-8003-000000000045','c7301030-2026-4000-8001-000000000005','¿Qué describe el desempeño?','El desempeño incorpora el contexto real donde la persona realiza actividades.','[{"text":"Lo que la persona hace en su entorno actual","correct":true},{"text":"Solo el nombre de la enfermedad","correct":false},{"text":"Solo una medida anatómica","correct":false},{"text":"La ausencia de toda influencia ambiental","correct":false}]'::jsonb,1,'Entrenamiento original · https://www.who.int/docs/default-source/classification/icf/icfchecklist.pdf',5,'mcq','{"content_batch":"es-s1-suite-20261030","academic_semester":1,"academic_year":1,"language":"es","origin":"original_training","external_expert_review":"pending","source_urls":["https://www.who.int/docs/default-source/classification/icf/icfchecklist.pdf","https://cdn.who.int/media/docs/default-source/classification/icf/drafticfpracticalmanual2.pdf"],"verified_at":"2026-10-30"}'::jsonb,'source_validated',true) ON CONFLICT(id) DO NOTHING;
INSERT INTO public.curriculum_quiz_questions (id,topic_id,question_text,explanation,options,difficulty,source_label,display_order,question_type,metadata,validation_status,is_published) VALUES ('c7301030-2026-4000-8003-000000000046','c7301030-2026-4000-8001-000000000005','¿Qué condiciones permiten interpretar mejor una valoración de capacidad?','La capacidad se interpreta en condiciones estandarizadas; deben aclararse las ayudas y el contexto.','[{"text":"Cualquier situación sin registrar las condiciones","correct":false},{"text":"Solo la opinión de un observador desconocido","correct":false},{"text":"El diagnóstico sin realizar ninguna valoración","correct":false},{"text":"Un entorno uniforme o estandarizado con condiciones y ayudas especificadas","correct":true}]'::jsonb,1,'Entrenamiento original · https://www.who.int/docs/default-source/classification/icf/icfchecklist.pdf',6,'mcq','{"content_batch":"es-s1-suite-20261030","academic_semester":1,"academic_year":1,"language":"es","origin":"original_training","external_expert_review":"pending","source_urls":["https://www.who.int/docs/default-source/classification/icf/icfchecklist.pdf","https://cdn.who.int/media/docs/default-source/classification/icf/drafticfpracticalmanual2.pdf"],"verified_at":"2026-10-30"}'::jsonb,'source_validated',true) ON CONFLICT(id) DO NOTHING;
INSERT INTO public.curriculum_quiz_questions (id,topic_id,question_text,explanation,options,difficulty,source_label,display_order,question_type,metadata,validation_status,is_published) VALUES ('c7301030-2026-4000-8003-000000000047','c7301030-2026-4000-8001-000000000005','Una rampa accesible permite entrar al centro. ¿Qué papel ambiental representa para esa persona?','El entorno puede mejorar el acceso y facilitar el funcionamiento.','[{"text":"Estructura anatómica","correct":false},{"text":"Limitación de actividad inevitable","correct":false},{"text":"Facilitador","correct":true},{"text":"Deficiencia de una función corporal","correct":false}]'::jsonb,2,'Entrenamiento original · https://www.who.int/docs/default-source/classification/icf/icfchecklist.pdf',7,'clinical_case','{"content_batch":"es-s1-suite-20261030","academic_semester":1,"academic_year":1,"language":"es","origin":"original_training","external_expert_review":"pending","source_urls":["https://www.who.int/docs/default-source/classification/icf/icfchecklist.pdf","https://cdn.who.int/media/docs/default-source/classification/icf/drafticfpracticalmanual2.pdf"],"verified_at":"2026-10-30"}'::jsonb,'source_validated',true) ON CONFLICT(id) DO NOTHING;
INSERT INTO public.curriculum_quiz_questions (id,topic_id,question_text,explanation,options,difficulty,source_label,display_order,question_type,metadata,validation_status,is_published) VALUES ('c7301030-2026-4000-8003-000000000048','c7301030-2026-4000-8001-000000000005','¿Qué tipo de entorno incluye la CIF además del físico?','Los factores ambientales incluyen aspectos físicos, sociales y actitudinales.','[{"text":"Solo el hormonal","correct":false},{"text":"Social y actitudinal","correct":true},{"text":"Solo el intracelular","correct":false},{"text":"Solo el genético","correct":false}]'::jsonb,1,'Entrenamiento original · https://www.who.int/docs/default-source/classification/icf/icfchecklist.pdf',8,'mcq','{"content_batch":"es-s1-suite-20261030","academic_semester":1,"academic_year":1,"language":"es","origin":"original_training","external_expert_review":"pending","source_urls":["https://www.who.int/docs/default-source/classification/icf/icfchecklist.pdf","https://cdn.who.int/media/docs/default-source/classification/icf/drafticfpracticalmanual2.pdf"],"verified_at":"2026-10-30"}'::jsonb,'source_validated',true) ON CONFLICT(id) DO NOTHING;
INSERT INTO public.curriculum_quiz_questions (id,topic_id,question_text,explanation,options,difficulty,source_label,display_order,question_type,metadata,validation_status,is_published) VALUES ('c7301030-2026-4000-8003-000000000049','c7301030-2026-4000-8001-000000000005','Una persona camina en consulta pero no puede acceder a su casa. ¿Qué información falta antes de interpretar la diferencia?','El contexto y las ayudas pueden explicar diferencias entre una tarea evaluada y su realización cotidiana.','[{"text":"Las condiciones de la vivienda, las ayudas y la tarea real","correct":true},{"text":"Solo el color de la ropa","correct":false},{"text":"Solo repetir el nombre del diagnóstico","correct":false},{"text":"Solo la marca del suelo de consulta","correct":false}]'::jsonb,2,'Entrenamiento original · https://www.who.int/docs/default-source/classification/icf/icfchecklist.pdf',9,'clinical_case','{"content_batch":"es-s1-suite-20261030","academic_semester":1,"academic_year":1,"language":"es","origin":"original_training","external_expert_review":"pending","source_urls":["https://www.who.int/docs/default-source/classification/icf/icfchecklist.pdf","https://cdn.who.int/media/docs/default-source/classification/icf/drafticfpracticalmanual2.pdf"],"verified_at":"2026-10-30"}'::jsonb,'source_validated',true) ON CONFLICT(id) DO NOTHING;
INSERT INTO public.curriculum_quiz_questions (id,topic_id,question_text,explanation,options,difficulty,source_label,display_order,question_type,metadata,validation_status,is_published) VALUES ('c7301030-2026-4000-8003-000000000050','c7301030-2026-4000-8001-000000000005','¿Qué conclusión es correcta cuando dos personas comparten un diagnóstico médico?','La CIF considera funcionamiento y contexto; un diagnóstico no determina por sí solo la situación funcional.','[{"text":"Deben tener idéntica participación","correct":false},{"text":"Necesitan siempre las mismas ayudas","correct":false},{"text":"Presentan obligatoriamente el mismo desempeño","correct":false},{"text":"Pueden presentar funcionamientos diferentes según sus características y contexto","correct":true}]'::jsonb,1,'Entrenamiento original · https://www.who.int/docs/default-source/classification/icf/icfchecklist.pdf',10,'mcq','{"content_batch":"es-s1-suite-20261030","academic_semester":1,"academic_year":1,"language":"es","origin":"original_training","external_expert_review":"pending","source_urls":["https://www.who.int/docs/default-source/classification/icf/icfchecklist.pdf","https://cdn.who.int/media/docs/default-source/classification/icf/drafticfpracticalmanual2.pdf"],"verified_at":"2026-10-30"}'::jsonb,'source_validated',true) ON CONFLICT(id) DO NOTHING;
INSERT INTO public.curriculum_quiz_questions (id,topic_id,question_text,explanation,options,difficulty,source_label,display_order,question_type,metadata,validation_status,is_published) VALUES ('c7301030-2026-4000-8003-000000000051','c7301030-2026-4000-8001-000000000006','¿Qué pregunta ayuda a acordar las prioridades al iniciar la conversación?','Acordar prioridades facilita una conversación centrada en lo que importa a la persona.','[{"text":"¿Qué le gustaría resolver hoy y qué le importa más?","correct":true},{"text":"¿Puede aceptar el plan antes de que lo explique?","correct":false},{"text":"¿Podemos omitir todas sus preguntas?","correct":false},{"text":"¿Prefiere que decida sin conocer sus objetivos?","correct":false}]'::jsonb,1,'Entrenamiento original · https://www.nice.org.uk/guidance/ng197/chapter/Recommendations',1,'mcq','{"content_batch":"es-s1-suite-20261030","academic_semester":1,"academic_year":1,"language":"es","origin":"original_training","external_expert_review":"pending","source_urls":["https://www.nice.org.uk/guidance/ng197/chapter/Recommendations"],"verified_at":"2026-10-30"}'::jsonb,'source_validated',true) ON CONFLICT(id) DO NOTHING;
INSERT INTO public.curriculum_quiz_questions (id,topic_id,question_text,explanation,options,difficulty,source_label,display_order,question_type,metadata,validation_status,is_published) VALUES ('c7301030-2026-4000-8003-000000000052','c7301030-2026-4000-8001-000000000006','¿Qué describe la técnica de explicar por partes y comprobar?','NICE recomienda dividir la información en unidades y comprobar lo comprendido.','[{"text":"Dar todas las instrucciones al final sin preguntas","correct":false},{"text":"Utilizar solo terminología técnica","correct":false},{"text":"Repetir más rápido si aparece una duda","correct":false},{"text":"Dar información manejable y verificar comprensión antes de continuar","correct":true}]'::jsonb,1,'Entrenamiento original · https://www.nice.org.uk/guidance/ng197/chapter/Recommendations',2,'mcq','{"content_batch":"es-s1-suite-20261030","academic_semester":1,"academic_year":1,"language":"es","origin":"original_training","external_expert_review":"pending","source_urls":["https://www.nice.org.uk/guidance/ng197/chapter/Recommendations"],"verified_at":"2026-10-30"}'::jsonb,'source_validated',true) ON CONFLICT(id) DO NOTHING;
INSERT INTO public.curriculum_quiz_questions (id,topic_id,question_text,explanation,options,difficulty,source_label,display_order,question_type,metadata,validation_status,is_published) VALUES ('c7301030-2026-4000-8003-000000000053','c7301030-2026-4000-8001-000000000006','¿Qué formulación aplica mejor el teach-back?','La reformulación permite comprobar qué se ha entendido y revisar la explicación.','[{"text":"Repita exactamente cada término técnico","correct":false},{"text":"Si no lo entiende, no podemos continuar","correct":false},{"text":"Para comprobar si me he explicado bien, ¿puede contarme con sus palabras el plan?","correct":true},{"text":"¿Ha entendido? Responda solo sí o no","correct":false}]'::jsonb,2,'Entrenamiento original · https://www.nice.org.uk/guidance/ng197/chapter/Recommendations',3,'clinical_case','{"content_batch":"es-s1-suite-20261030","academic_semester":1,"academic_year":1,"language":"es","origin":"original_training","external_expert_review":"pending","source_urls":["https://www.nice.org.uk/guidance/ng197/chapter/Recommendations"],"verified_at":"2026-10-30"}'::jsonb,'source_validated',true) ON CONFLICT(id) DO NOTHING;
INSERT INTO public.curriculum_quiz_questions (id,topic_id,question_text,explanation,options,difficulty,source_label,display_order,question_type,metadata,validation_status,is_published) VALUES ('c7301030-2026-4000-8003-000000000054','c7301030-2026-4000-8001-000000000006','¿Qué debe evaluarse mediante teach-back?','El teach-back es una comprobación de comprensión, no un examen de inteligencia.','[{"text":"El nivel de dolor mediante una prueba de memoria","correct":false},{"text":"Si la información se ha explicado y comprendido con claridad","correct":true},{"text":"La inteligencia global del paciente","correct":false},{"text":"La obediencia sin preguntas","correct":false}]'::jsonb,1,'Entrenamiento original · https://www.nice.org.uk/guidance/ng197/chapter/Recommendations',4,'mcq','{"content_batch":"es-s1-suite-20261030","academic_semester":1,"academic_year":1,"language":"es","origin":"original_training","external_expert_review":"pending","source_urls":["https://www.nice.org.uk/guidance/ng197/chapter/Recommendations"],"verified_at":"2026-10-30"}'::jsonb,'source_validated',true) ON CONFLICT(id) DO NOTHING;
INSERT INTO public.curriculum_quiz_questions (id,topic_id,question_text,explanation,options,difficulty,source_label,display_order,question_type,metadata,validation_status,is_published) VALUES ('c7301030-2026-4000-8003-000000000055','c7301030-2026-4000-8001-000000000006','¿Qué información debe acompañar la comparación de opciones?','Las decisiones compartidas relacionan opciones y evidencia con las preferencias de la persona.','[{"text":"Beneficios, riesgos, consecuencias y relación con los objetivos personales","correct":true},{"text":"Solo la opción favorita del profesional","correct":false},{"text":"Solo el precio sin más contexto","correct":false},{"text":"Solo la experiencia de un conocido","correct":false}]'::jsonb,1,'Entrenamiento original · https://www.nice.org.uk/guidance/ng197/chapter/Recommendations',5,'mcq','{"content_batch":"es-s1-suite-20261030","academic_semester":1,"academic_year":1,"language":"es","origin":"original_training","external_expert_review":"pending","source_urls":["https://www.nice.org.uk/guidance/ng197/chapter/Recommendations"],"verified_at":"2026-10-30"}'::jsonb,'source_validated',true) ON CONFLICT(id) DO NOTHING;
INSERT INTO public.curriculum_quiz_questions (id,topic_id,question_text,explanation,options,difficulty,source_label,display_order,question_type,metadata,validation_status,is_published) VALUES ('c7301030-2026-4000-8003-000000000056','c7301030-2026-4000-8001-000000000006','¿Cuándo procede implicar a un familiar en la conversación?','Se pregunta si la persona quiere implicar a familiares o apoyos.','[{"text":"Siempre, sin preguntar","correct":false},{"text":"Solo si el familiar sustituye todas sus decisiones","correct":false},{"text":"Nunca, aunque la persona lo solicite","correct":false},{"text":"Cuando la persona desea ese apoyo, considerando el contexto","correct":true}]'::jsonb,1,'Entrenamiento original · https://www.nice.org.uk/guidance/ng197/chapter/Recommendations',6,'mcq','{"content_batch":"es-s1-suite-20261030","academic_semester":1,"academic_year":1,"language":"es","origin":"original_training","external_expert_review":"pending","source_urls":["https://www.nice.org.uk/guidance/ng197/chapter/Recommendations"],"verified_at":"2026-10-30"}'::jsonb,'source_validated',true) ON CONFLICT(id) DO NOTHING;
INSERT INTO public.curriculum_quiz_questions (id,topic_id,question_text,explanation,options,difficulty,source_label,display_order,question_type,metadata,validation_status,is_published) VALUES ('c7301030-2026-4000-8003-000000000057','c7301030-2026-4000-8001-000000000006','Una explicación no se comprende bien por una barrera lingüística. ¿Qué opción favorece la participación?','El apoyo adicional puede ayudar a comprender la información y participar en decisiones.','[{"text":"Pedir una firma sin aclaraciones","correct":false},{"text":"Excluir a la persona de la conversación","correct":false},{"text":"Valorar apoyo de interpretación y recursos accesibles","correct":true},{"text":"Hablar cada vez más rápido","correct":false}]'::jsonb,2,'Entrenamiento original · https://www.nice.org.uk/guidance/ng197/chapter/Recommendations',7,'clinical_case','{"content_batch":"es-s1-suite-20261030","academic_semester":1,"academic_year":1,"language":"es","origin":"original_training","external_expert_review":"pending","source_urls":["https://www.nice.org.uk/guidance/ng197/chapter/Recommendations"],"verified_at":"2026-10-30"}'::jsonb,'source_validated',true) ON CONFLICT(id) DO NOTHING;
INSERT INTO public.curriculum_quiz_questions (id,topic_id,question_text,explanation,options,difficulty,source_label,display_order,question_type,metadata,validation_status,is_published) VALUES ('c7301030-2026-4000-8003-000000000058','c7301030-2026-4000-8001-000000000006','¿Qué conviene aclarar al cerrar la consulta?','Un resumen final compartido comprueba que se entiende el plan y su seguimiento.','[{"text":"Que no podrán plantearse nuevas dudas","correct":false},{"text":"Lo acordado, los siguientes pasos y cuándo se revisará","correct":true},{"text":"Solo la duración de la siguiente consulta","correct":false},{"text":"Únicamente el nombre de la técnica","correct":false}]'::jsonb,1,'Entrenamiento original · https://www.nice.org.uk/guidance/ng197/chapter/Recommendations',8,'mcq','{"content_batch":"es-s1-suite-20261030","academic_semester":1,"academic_year":1,"language":"es","origin":"original_training","external_expert_review":"pending","source_urls":["https://www.nice.org.uk/guidance/ng197/chapter/Recommendations"],"verified_at":"2026-10-30"}'::jsonb,'source_validated',true) ON CONFLICT(id) DO NOTHING;
INSERT INTO public.curriculum_quiz_questions (id,topic_id,question_text,explanation,options,difficulty,source_label,display_order,question_type,metadata,validation_status,is_published) VALUES ('c7301030-2026-4000-8003-000000000059','c7301030-2026-4000-8001-000000000006','¿Qué función tiene una ayuda de decisión?','Las ayudas de decisión informan y apoyan; no sustituyen la consulta ni imponen una alternativa.','[{"text":"Apoyar la conversación sobre opciones y preferencias","correct":true},{"text":"Reemplazar toda conversación clínica","correct":false},{"text":"Garantizar que todos elijan lo mismo","correct":false},{"text":"Ocultar incertidumbres para simplificar","correct":false}]'::jsonb,1,'Entrenamiento original · https://www.nice.org.uk/guidance/ng197/chapter/Recommendations',9,'mcq','{"content_batch":"es-s1-suite-20261030","academic_semester":1,"academic_year":1,"language":"es","origin":"original_training","external_expert_review":"pending","source_urls":["https://www.nice.org.uk/guidance/ng197/chapter/Recommendations"],"verified_at":"2026-10-30"}'::jsonb,'source_validated',true) ON CONFLICT(id) DO NOTHING;
INSERT INTO public.curriculum_quiz_questions (id,topic_id,question_text,explanation,options,difficulty,source_label,display_order,question_type,metadata,validation_status,is_published) VALUES ('c7301030-2026-4000-8003-000000000060','c7301030-2026-4000-8001-000000000006','La persona prefiere una opción distinta de la favorita del profesional. ¿Qué procede explorar?','Las personas pueden valorar de forma diferente beneficios y riesgos; la decisión compartida explora esas preferencias.','[{"text":"Considerar la diferencia una falta de respeto","correct":false},{"text":"Eliminar toda oportunidad de preguntas","correct":false},{"text":"Registrar que no puede decidir por discrepar","correct":false},{"text":"Sus razones, preferencias y comprensión de beneficios y riesgos","correct":true}]'::jsonb,2,'Entrenamiento original · https://www.nice.org.uk/guidance/ng197/chapter/Recommendations',10,'clinical_case','{"content_batch":"es-s1-suite-20261030","academic_semester":1,"academic_year":1,"language":"es","origin":"original_training","external_expert_review":"pending","source_urls":["https://www.nice.org.uk/guidance/ng197/chapter/Recommendations"],"verified_at":"2026-10-30"}'::jsonb,'source_validated',true) ON CONFLICT(id) DO NOTHING;
UPDATE public.curriculum_lessons SET content='### Objetivos de repaso

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

Material de entrenamiento original basado en fuentes; no es un examen oficial.',updated_at=now() WHERE id='21afcaf4-82c8-4ea6-8778-dd0ee108ec6b' AND (content='### Objetivos de repaso
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

Material de entrenamiento original basado en fuentes; no es un examen oficial.' OR content='### Objetivos de repaso

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

Material de entrenamiento original basado en fuentes; no es un examen oficial.');
UPDATE public.curriculum_lessons SET content='Fisiología II introduce conceptos de neurociencia relevantes para comprender el movimiento y la función. La neuroplasticidad describe la capacidad del sistema nervioso para modificar su organización y funcionamiento en respuesta a la experiencia y al aprendizaje.

El sistema somatosensorial aporta información sobre el cuerpo, mientras que los sistemas visual y vestibular también participan en la orientación y el control postural. El control motor integra información sensorial y órdenes motoras para producir movimientos adaptados.

El aprendizaje motor, la atención y la memoria influyen en la adquisición y repetición de habilidades. Estos conceptos ayudan a comprender por qué la práctica, la retroalimentación y el contexto son importantes durante la rehabilitación.

En rehabilitación, la práctica repetida cobra sentido cuando el paciente recibe información útil sobre el resultado y la ejecución. El feedback permite ajustar el movimiento, mientras que la repetición en contextos variados favorece el aprendizaje y la transferencia a tareas funcionales. La dificultad debe progresar sin perder seguridad ni calidad de movimiento.',updated_at=now() WHERE id='3bd5d230-90e8-4e09-9487-b7a75accb5a2' AND (content='Fisiología II introduce conceptos de neurociencia relevantes para comprender el movimiento y la función. La neuroplasticidad describe la capacidad del sistema nervioso para modificar su organización y funcionamiento en respuesta a la experiencia y al aprendizaje.\n\nEl sistema somatosensorial aporta información sobre el cuerpo, mientras que los sistemas visual y vestibular también participan en la orientación y el control postural. El control motor integra información sensorial y órdenes motoras para producir movimientos adaptados.\n\nEl aprendizaje motor, la atención y la memoria influyen en la adquisición y repetición de habilidades. Estos conceptos ayudan a comprender por qué la práctica, la retroalimentación y el contexto son importantes durante la rehabilitación.

En rehabilitación, la práctica repetida cobra sentido cuando el paciente recibe información útil sobre el resultado y la ejecución. El feedback permite ajustar el movimiento, mientras que la repetición en contextos variados favorece el aprendizaje y la transferencia a tareas funcionales. La dificultad debe progresar sin perder seguridad ni calidad de movimiento.' OR content='Fisiología II introduce conceptos de neurociencia relevantes para comprender el movimiento y la función. La neuroplasticidad describe la capacidad del sistema nervioso para modificar su organización y funcionamiento en respuesta a la experiencia y al aprendizaje.

El sistema somatosensorial aporta información sobre el cuerpo, mientras que los sistemas visual y vestibular también participan en la orientación y el control postural. El control motor integra información sensorial y órdenes motoras para producir movimientos adaptados.

El aprendizaje motor, la atención y la memoria influyen en la adquisición y repetición de habilidades. Estos conceptos ayudan a comprender por qué la práctica, la retroalimentación y el contexto son importantes durante la rehabilitación.

En rehabilitación, la práctica repetida cobra sentido cuando el paciente recibe información útil sobre el resultado y la ejecución. El feedback permite ajustar el movimiento, mientras que la repetición en contextos variados favorece el aprendizaje y la transferencia a tareas funcionales. La dificultad debe progresar sin perder seguridad ni calidad de movimiento.');
UPDATE public.curriculum_lessons SET content='La historia clínica organiza la información relevante de la persona: motivo de consulta, antecedentes, síntomas, evolución y repercusión funcional. La entrevista clínica permite completar esta información mediante preguntas claras y dirigidas.

La semiología ayuda a describir signos y síntomas de forma ordenada. En fisioterapia, esta información se relaciona con la valoración de las capacidades funcionales y con el análisis del movimiento y de la actividad.

El diagnóstico funcional de fisioterapia sintetiza los hallazgos relevantes para orientar los objetivos de intervención. No consiste únicamente en nombrar una patología, sino en comprender cómo la situación afecta a la función.

### Approfondissement

Una buena historia clínica no es una lista de datos aislados. Debe organizar la información relevante, relacionar síntomas y evolución con el impacto funcional y orientar la exploración. El diagnóstico funcional sintetiza lo que la persona puede o no puede hacer, qué factores lo limitan y qué objetivos de fisioterapia son prioritarios.',updated_at=now() WHERE id='7e9e37d5-20fa-49fc-bbbf-aee1bc790db5' AND (content='La historia clínica organiza la información relevante de la persona: motivo de consulta, antecedentes, síntomas, evolución y repercusión funcional. La entrevista clínica permite completar esta información mediante preguntas claras y dirigidas.\n\nLa semiología ayuda a describir signos y síntomas de forma ordenada. En fisioterapia, esta información se relaciona con la valoración de las capacidades funcionales y con el análisis del movimiento y de la actividad.\n\nEl diagnóstico funcional de fisioterapia sintetiza los hallazgos relevantes para orientar los objetivos de intervención. No consiste únicamente en nombrar una patología, sino en comprender cómo la situación afecta a la función.

### Approfondissement
Una buena historia clínica no es una lista de datos aislados. Debe organizar la información relevante, relacionar síntomas y evolución con el impacto funcional y orientar la exploración. El diagnóstico funcional sintetiza lo que la persona puede o no puede hacer, qué factores lo limitan y qué objetivos de fisioterapia son prioritarios.' OR content='La historia clínica organiza la información relevante de la persona: motivo de consulta, antecedentes, síntomas, evolución y repercusión funcional. La entrevista clínica permite completar esta información mediante preguntas claras y dirigidas.

La semiología ayuda a describir signos y síntomas de forma ordenada. En fisioterapia, esta información se relaciona con la valoración de las capacidades funcionales y con el análisis del movimiento y de la actividad.

El diagnóstico funcional de fisioterapia sintetiza los hallazgos relevantes para orientar los objetivos de intervención. No consiste únicamente en nombrar una patología, sino en comprender cómo la situación afecta a la función.

### Approfondissement

Una buena historia clínica no es una lista de datos aislados. Debe organizar la información relevante, relacionar síntomas y evolución con el impacto funcional y orientar la exploración. El diagnóstico funcional sintetiza lo que la persona puede o no puede hacer, qué factores lo limitan y qué objetivos de fisioterapia son prioritarios.');
UPDATE public.curriculum_lessons SET content='### Objetivos de repaso

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

Ejercicios originales de entrenamiento; no son preguntas de examen autenticadas.',updated_at=now() WHERE id='ab7d1b48-00b2-45f3-97ae-c055c7a6a0e0' AND (content='### Objetivos de repaso
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

Ejercicios originales de entrenamiento; no son preguntas de examen autenticadas.' OR content='### Objetivos de repaso

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

Ejercicios originales de entrenamiento; no son preguntas de examen autenticadas.');
UPDATE public.curriculum_lessons SET content='El ejercicio terapéutico utiliza movimientos y actividades planificadas con un objetivo funcional. No se trata simplemente de hacer ejercicio: en fisioterapia, cada propuesta debe relacionarse con una capacidad que se quiere mantener, recuperar o mejorar.

La planificación tiene en cuenta las capacidades físicas básicas y la respuesta de la persona al esfuerzo. La progresión debe ser gradual y coherente con el nivel funcional observado.

La prescripción forma parte de la intervención fisioterapéutica. El estudiante debe aprender a relacionar el ejercicio elegido con un objetivo concreto, observar la tolerancia y adaptar la dificultad cuando sea necesario.

### Approfondissement

Un ejercicio terapéutico debe tener un objetivo observable. Por ejemplo, mejorar la capacidad de levantarse de una silla no exige el mismo trabajo que mejorar el equilibrio o la movilidad de hombro. La progresión puede modificarse aumentando repeticiones, resistencia, amplitud o complejidad, siempre observando la tolerancia. La respuesta del paciente sirve para decidir si mantener, facilitar o aumentar la dificultad.',updated_at=now() WHERE id='3d6bb405-866f-4daf-acb9-618bd8cc2100' AND (content='El ejercicio terapéutico utiliza movimientos y actividades planificadas con un objetivo funcional. No se trata simplemente de hacer ejercicio: en fisioterapia, cada propuesta debe relacionarse con una capacidad que se quiere mantener, recuperar o mejorar.\n\nLa planificación tiene en cuenta las capacidades físicas básicas y la respuesta de la persona al esfuerzo. La progresión debe ser gradual y coherente con el nivel funcional observado.\n\nLa prescripción forma parte de la intervención fisioterapéutica. El estudiante debe aprender a relacionar el ejercicio elegido con un objetivo concreto, observar la tolerancia y adaptar la dificultad cuando sea necesario.

### Approfondissement
Un ejercicio terapéutico debe tener un objetivo observable. Por ejemplo, mejorar la capacidad de levantarse de una silla no exige el mismo trabajo que mejorar el equilibrio o la movilidad de hombro. La progresión puede modificarse aumentando repeticiones, resistencia, amplitud o complejidad, siempre observando la tolerancia. La respuesta del paciente sirve para decidir si mantener, facilitar o aumentar la dificultad.' OR content='El ejercicio terapéutico utiliza movimientos y actividades planificadas con un objetivo funcional. No se trata simplemente de hacer ejercicio: en fisioterapia, cada propuesta debe relacionarse con una capacidad que se quiere mantener, recuperar o mejorar.

La planificación tiene en cuenta las capacidades físicas básicas y la respuesta de la persona al esfuerzo. La progresión debe ser gradual y coherente con el nivel funcional observado.

La prescripción forma parte de la intervención fisioterapéutica. El estudiante debe aprender a relacionar el ejercicio elegido con un objetivo concreto, observar la tolerancia y adaptar la dificultad cuando sea necesario.

### Approfondissement

Un ejercicio terapéutico debe tener un objetivo observable. Por ejemplo, mejorar la capacidad de levantarse de una silla no exige el mismo trabajo que mejorar el equilibrio o la movilidad de hombro. La progresión puede modificarse aumentando repeticiones, resistencia, amplitud o complejidad, siempre observando la tolerancia. La respuesta del paciente sirve para decidir si mantener, facilitar o aumentar la dificultad.');
UPDATE public.curriculum_lessons SET content='### Objetivos de repaso

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

Material de repaso original basado en las fuentes enlazadas; no es una reproducción del curso ni un examen oficial.',updated_at=now() WHERE id='502486f5-ff65-4a23-82fe-40d4408de8d1' AND (content='### Objetivos de repaso
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

Material de repaso original basado en las fuentes enlazadas; no es una reproducción del curso ni un examen oficial.' OR content='### Objetivos de repaso

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

Material de repaso original basado en las fuentes enlazadas; no es una reproducción del curso ni un examen oficial.');
UPDATE public.curriculum_lessons SET content='Comprender al paciente exige identificar el vocabulario de dolor y función sin interpretar automáticamente un diagnóstico. Frases como «Me duele la cadera cuando camino» o «No puedo apoyar bien la pierna» describen una molestia y una limitation funcional concreta.

También son frecuentes expresiones como «Tengo rigidez por la mañana» o «El dolor mejora cuando descanso». El estudiante debe repérer douleur, appui, raideur, marche et repos dans leur contexte clinique.

L’objectif est de comprendre ce que le patient exprime, puis de savoir reformuler l’information avant toute interprétation clinique.

### Cómo analizar el mensaje

Primero se identifica el síntoma expresado por el paciente, después la actividad afectada y por último el factor que modifica la molestia. “Me duele la cadera cuando camino” contiene dolor + localización + actividad; “no puedo apoyar bien la pierna” señala una limitación funcional. Esta lectura por bloques ayuda a reformular con precisión sin transformar automáticamente la plainte en diagnostic.',updated_at=now() WHERE id='865fe31e-5a66-4b18-a370-9273f660c296' AND (content='Comprender al paciente exige identificar el vocabulario de dolor y función sin interpretar automáticamente un diagnóstico. Frases como «Me duele la cadera cuando camino» o «No puedo apoyar bien la pierna» describen una molestia y una limitation funcional concreta.\n\nTambién son frecuentes expresiones como «Tengo rigidez por la mañana» o «El dolor mejora cuando descanso». El estudiante debe repérer douleur, appui, raideur, marche et repos dans leur contexte clinique.\n\nL’objectif est de comprendre ce que le patient exprime, puis de savoir reformuler l’information avant toute interprétation clinique.

### Cómo analizar el mensaje
Primero se identifica el síntoma expresado por el paciente, después la actividad afectada y por último el factor que modifica la molestia. “Me duele la cadera cuando camino” contiene dolor + localización + actividad; “no puedo apoyar bien la pierna” señala una limitación funcional. Esta lectura por bloques ayuda a reformular con precisión sin transformar automáticamente la plainte en diagnostic.' OR content='Comprender al paciente exige identificar el vocabulario de dolor y función sin interpretar automáticamente un diagnóstico. Frases como «Me duele la cadera cuando camino» o «No puedo apoyar bien la pierna» describen una molestia y una limitation funcional concreta.

También son frecuentes expresiones como «Tengo rigidez por la mañana» o «El dolor mejora cuando descanso». El estudiante debe repérer douleur, appui, raideur, marche et repos dans leur contexte clinique.

L’objectif est de comprendre ce que le patient exprime, puis de savoir reformuler l’information avant toute interprétation clinique.

### Cómo analizar el mensaje

Primero se identifica el síntoma expresado por el paciente, después la actividad afectada y por último el factor que modifica la molestia. “Me duele la cadera cuando camino” contiene dolor + localización + actividad; “no puedo apoyar bien la pierna” señala una limitación funcional. Esta lectura por bloques ayuda a reformular con precisión sin transformar automáticamente la plainte en diagnostic.');
UPDATE public.curriculum_lessons SET content='El rango de movimiento del hombro describe cuánto puede desplazarse la articulación en diferentes direcciones. En la valoración se observa la movilidad y se buscan limitaciones, rigidez o debilidad que puedan interferir con la función.

Los ejercicios pueden dirigirse a estirar y fortalecer los músculos que rodean el hombro y la escápula. El objetivo no es solamente aumentar fuerza, sino favorecer un movimiento más eficaz y funcional.

Durante la práctica, el estudiante debe relacionar movilidad, fuerza y síntomas con actividades concretas del miembro superior, evitando interpretar un dato aislado fuera del conjunto de la valoración.

### Raisonnement simple

Une épaule peut présenter une limitation de mouvement, une faiblesse, une raideur ou une combinaison de ces éléments. L’exercice choisi doit donc être relié à ce qui est observé : étirer lorsqu’un travail de mobilité est recherché, renforcer lorsqu’un déficit de force est identifié, et toujours vérifier le retentissement fonctionnel. Le suivi s’appuie sur l’évolution des symptômes et de la capacité à réaliser les activités du membre supérieur.',updated_at=now() WHERE id='ca4270be-ba6e-4442-b152-33c8472f679c' AND (content='El rango de movimiento del hombro describe cuánto puede desplazarse la articulación en diferentes direcciones. En la valoración se observa la movilidad y se buscan limitaciones, rigidez o debilidad que puedan interferir con la función.\n\nLos ejercicios pueden dirigirse a estirar y fortalecer los músculos que rodean el hombro y la escápula. El objetivo no es solamente aumentar fuerza, sino favorecer un movimiento más eficaz y funcional.\n\nDurante la práctica, el estudiante debe relacionar movilidad, fuerza y síntomas con actividades concretas del miembro superior, evitando interpretar un dato aislado fuera del conjunto de la valoración.

### Raisonnement simple
Une épaule peut présenter une limitation de mouvement, une faiblesse, une raideur ou une combinaison de ces éléments. L’exercice choisi doit donc être relié à ce qui est observé : étirer lorsqu’un travail de mobilité est recherché, renforcer lorsqu’un déficit de force est identifié, et toujours vérifier le retentissement fonctionnel. Le suivi s’appuie sur l’évolution des symptômes et de la capacité à réaliser les activités du membre supérieur.' OR content='El rango de movimiento del hombro describe cuánto puede desplazarse la articulación en diferentes direcciones. En la valoración se observa la movilidad y se buscan limitaciones, rigidez o debilidad que puedan interferir con la función.

Los ejercicios pueden dirigirse a estirar y fortalecer los músculos que rodean el hombro y la escápula. El objetivo no es solamente aumentar fuerza, sino favorecer un movimiento más eficaz y funcional.

Durante la práctica, el estudiante debe relacionar movilidad, fuerza y síntomas con actividades concretas del miembro superior, evitando interpretar un dato aislado fuera del conjunto de la valoración.

### Raisonnement simple

Une épaule peut présenter une limitation de mouvement, une faiblesse, une raideur ou une combinaison de ces éléments. L’exercice choisi doit donc être relié à ce qui est observé : étirer lorsqu’un travail de mobilité est recherché, renforcer lorsqu’un déficit de force est identifié, et toujours vérifier le retentissement fonctionnel. Le suivi s’appuie sur l’évolution des symptômes et de la capacité à réaliser les activités du membre supérieur.');
UPDATE public.curriculum_lessons SET content='En la exploración cardio-respiratoria se utilizan varios signos y términos básicos. El pulso permite estimar la frecuencia cardíaca; la frecuencia respiratoria describe el número de respiraciones por minuto; la presión arterial es otro signo vital importante.

Durante el ejercicio o una prueba de esfuerzo también pueden aparecer síntomas relevantes como falta de aire, palpitaciones, mareo o dolor torácico. Reconocer este vocabulario ayuda a comprender las indicaciones y a comunicar síntomas con precisión.

Equivalencias útiles: pulso = pouls, frecuencia cardíaca = fréquence cardiaque, presión arterial = pression artérielle, falta de aire = essoufflement.

### Approfondissement

Para interpretar correctamente una situación cardio-respiratoria, conviene relacionar cada término con una medida o un síntoma concreto. “Pulso” y “frecuencia cardíaca” se refieren al ritmo del corazón; “frecuencia respiratoria” al número de respiraciones por minuto; “presión arterial” a la tensión ejercida por la sangre en las arterias. Durante el esfuerzo, síntomas como falta de aire, palpitaciones, mareo o dolor torácico deben describirse con precisión, indicando cuándo aparecen y si obligan a detener la actividad.',updated_at=now() WHERE id='58a2ea17-3a47-4551-95eb-8be4924678bc' AND (content='En la exploración cardio-respiratoria se utilizan varios signos y términos básicos. El pulso permite estimar la frecuencia cardíaca; la frecuencia respiratoria describe el número de respiraciones por minuto; la presión arterial es otro signo vital importante.\n\nDurante el ejercicio o una prueba de esfuerzo también pueden aparecer síntomas relevantes como falta de aire, palpitaciones, mareo o dolor torácico. Reconocer este vocabulario ayuda a comprender las indicaciones y a comunicar síntomas con precisión.\n\nEquivalencias útiles: pulso = pouls, frecuencia cardíaca = fréquence cardiaque, presión arterial = pression artérielle, falta de aire = essoufflement.

### Approfondissement
Para interpretar correctamente una situación cardio-respiratoria, conviene relacionar cada término con una medida o un síntoma concreto. “Pulso” y “frecuencia cardíaca” se refieren al ritmo del corazón; “frecuencia respiratoria” al número de respiraciones por minuto; “presión arterial” a la tensión ejercida por la sangre en las arterias. Durante el esfuerzo, síntomas como falta de aire, palpitaciones, mareo o dolor torácico deben describirse con precisión, indicando cuándo aparecen y si obligan a detener la actividad.' OR content='En la exploración cardio-respiratoria se utilizan varios signos y términos básicos. El pulso permite estimar la frecuencia cardíaca; la frecuencia respiratoria describe el número de respiraciones por minuto; la presión arterial es otro signo vital importante.

Durante el ejercicio o una prueba de esfuerzo también pueden aparecer síntomas relevantes como falta de aire, palpitaciones, mareo o dolor torácico. Reconocer este vocabulario ayuda a comprender las indicaciones y a comunicar síntomas con precisión.

Equivalencias útiles: pulso = pouls, frecuencia cardíaca = fréquence cardiaque, presión arterial = pression artérielle, falta de aire = essoufflement.

### Approfondissement

Para interpretar correctamente una situación cardio-respiratoria, conviene relacionar cada término con una medida o un síntoma concreto. “Pulso” y “frecuencia cardíaca” se refieren al ritmo del corazón; “frecuencia respiratoria” al número de respiraciones por minuto; “presión arterial” a la tensión ejercida por la sangre en las arterias. Durante el esfuerzo, síntomas como falta de aire, palpitaciones, mareo o dolor torácico deben describirse con precisión, indicando cuándo aparecen y si obligan a detener la actividad.');
UPDATE public.curriculum_lessons SET content='El vocabulario neuromotor aparece constantemente en la valoración funcional. Equilibrio describe la capacidad de mantener o recuperar una posición estable; coordinación se refiere a la organización adecuada de los movimientos; sensibilidad permite percibir estímulos procedentes del cuerpo y del entorno.

Marcha significa caminar. Una caída puede relacionarse con problemas de equilibrio, debilidad o alteraciones de la marcha, aunque estos términos por sí solos no establecen un diagnóstico.

En contexto clínico conviene reconocer también nervio, control motor y estabilidad. Dominar estas palabras permite comprender mejor las consignas, la entrevista y las situaciones funcionales descritas por el paciente.

### Aplicación clínica

Ante una queja de inestabilidad, separa equilibrio, coordinación, sensibilidad, fuerza y marcha. Preguntas simples permiten saber si el problema aparece de pie, al caminar, al girar o dans l’obscurité. El objetivo inicial es describir el déficit funcional antes de buscar una explicación causal.',updated_at=now() WHERE id='77ed1803-59cd-44c7-8d0a-67db4e96d2a7' AND (content='El vocabulario neuromotor aparece constantemente en la valoración funcional. Equilibrio describe la capacidad de mantener o recuperar una posición estable; coordinación se refiere a la organización adecuada de los movimientos; sensibilidad permite percibir estímulos procedentes del cuerpo y del entorno.\n\nMarcha significa caminar. Una caída puede relacionarse con problemas de equilibrio, debilidad o alteraciones de la marcha, aunque estos términos por sí solos no establecen un diagnóstico.\n\nEn contexto clínico conviene reconocer también nervio, control motor y estabilidad. Dominar estas palabras permite comprender mejor las consignas, la entrevista y las situaciones funcionales descritas por el paciente.

### Aplicación clínica

Ante una queja de inestabilidad, separa equilibrio, coordinación, sensibilidad, fuerza y marcha. Preguntas simples permiten saber si el problema aparece de pie, al caminar, al girar o dans l’obscurité. El objetivo inicial es describir el déficit funcional antes de buscar una explicación causal.' OR content='El vocabulario neuromotor aparece constantemente en la valoración funcional. Equilibrio describe la capacidad de mantener o recuperar una posición estable; coordinación se refiere a la organización adecuada de los movimientos; sensibilidad permite percibir estímulos procedentes del cuerpo y del entorno.

Marcha significa caminar. Una caída puede relacionarse con problemas de equilibrio, debilidad o alteraciones de la marcha, aunque estos términos por sí solos no establecen un diagnóstico.

En contexto clínico conviene reconocer también nervio, control motor y estabilidad. Dominar estas palabras permite comprender mejor las consignas, la entrevista y las situaciones funcionales descritas por el paciente.

### Aplicación clínica

Ante una queja de inestabilidad, separa equilibrio, coordinación, sensibilidad, fuerza y marcha. Preguntas simples permiten saber si el problema aparece de pie, al caminar, al girar o dans l’obscurité. El objetivo inicial es describir el déficit funcional antes de buscar una explicación causal.');
UPDATE public.curriculum_lessons SET content='La muñeca conecta el antebrazo con la mano y permite orientar la mano para las actividades de prensión, apoyo y manipulación. En esta región pasan tendones que movilizan los dedos y también estructuras nerviosas importantes.

El nervio mediano atraviesa el túnel carpiano. Una alteración en esta zona puede modificar la sensibilidad y la función de la mano. Por eso, en fisioterapia es útil relacionar movilidad de muñeca, deslizamiento tendinoso, sensibilidad y capacidad funcional.

Vocabulario útil: muñeca = poignet, mano = main, nervio mediano = nerf médian, tendón = tendon, sensibilidad = sensibilité.

### Relación estructura-función

La muñeca no se estudia de forma aislada de la mano. Una limitación de movilidad puede modificar la orientación de la mano durante la prensión o el apoyo. Del mismo modo, sensibilidad y función deben relacionarse con el trayecto nervioso y con las tareas que la persona tiene dificultad para realizar. En una exploración básica, el estudiante distingue por tanto movilidad, sensibilidad y capacidad funcional antes de sacar conclusiones.',updated_at=now() WHERE id='599a84b0-9acf-45a1-9cf9-101fa2b2e192' AND (content='La muñeca conecta el antebrazo con la mano y permite orientar la mano para las actividades de prensión, apoyo y manipulación. En esta región pasan tendones que movilizan los dedos y también estructuras nerviosas importantes.\n\nEl nervio mediano atraviesa el túnel carpiano. Una alteración en esta zona puede modificar la sensibilidad y la función de la mano. Por eso, en fisioterapia es útil relacionar movilidad de muñeca, deslizamiento tendinoso, sensibilidad y capacidad funcional.\n\nVocabulario útil: muñeca = poignet, mano = main, nervio mediano = nerf médian, tendón = tendon, sensibilidad = sensibilité.

### Relación estructura-función
La muñeca no se estudia de forma aislada de la mano. Una limitación de movilidad puede modificar la orientación de la mano durante la prensión o el apoyo. Del mismo modo, sensibilidad y función deben relacionarse con el trayecto nervioso y con las tareas que la persona tiene dificultad para realizar. En una exploración básica, el estudiante distingue por tanto movilidad, sensibilidad y capacidad funcional antes de sacar conclusiones.' OR content='La muñeca conecta el antebrazo con la mano y permite orientar la mano para las actividades de prensión, apoyo y manipulación. En esta región pasan tendones que movilizan los dedos y también estructuras nerviosas importantes.

El nervio mediano atraviesa el túnel carpiano. Una alteración en esta zona puede modificar la sensibilidad y la función de la mano. Por eso, en fisioterapia es útil relacionar movilidad de muñeca, deslizamiento tendinoso, sensibilidad y capacidad funcional.

Vocabulario útil: muñeca = poignet, mano = main, nervio mediano = nerf médian, tendón = tendon, sensibilidad = sensibilité.

### Relación estructura-función

La muñeca no se estudia de forma aislada de la mano. Una limitación de movilidad puede modificar la orientación de la mano durante la prensión o el apoyo. Del mismo modo, sensibilidad y función deben relacionarse con el trayecto nervioso y con las tareas que la persona tiene dificultad para realizar. En una exploración básica, el estudiante distingue por tanto movilidad, sensibilidad y capacidad funcional antes de sacar conclusiones.');
UPDATE public.curriculum_lessons SET content='### Objetivos de repaso

Distinguir aprendizaje por asociación de estímulos y aprendizaje por consecuencias; utilizar correctamente refuerzo positivo, refuerzo negativo y castigo. Este bloque complementa los modelos y la comunicación del programa de Psicología.

### Dos formas de aprendizaje

En el condicionamiento clásico se aprende una relación entre estímulos. Un estímulo inicialmente neutro, después de asociarse con otro que provoca una respuesta, puede terminar desencadenando una respuesta aprendida.
En el condicionamiento operante se relaciona una conducta con sus consecuencias: estas pueden aumentar o disminuir su probabilidad futura.

### Vocabulario del condicionamiento clásico

El estímulo incondicionado desencadena una respuesta sin aprendizaje previo. La respuesta incondicionada es esa reacción no aprendida. El estímulo condicionado adquiere su efecto mediante la asociación; la respuesta condicionada es la respuesta aprendida.
No confundas estímulo, que se presenta, con respuesta, que hace el organismo. Una reacción anticipatoria aprendida no demuestra por sí sola una nueva lesión.

### Refuerzo y castigo

Refuerzo significa que aumenta la probabilidad de una conducta. Castigo significa que disminuye. Positivo indica que se añade un estímulo; negativo, que se retira. Estas palabras no equivalen a bueno y malo.
Refuerzo positivo: se añade una consecuencia y la conducta aumenta. Refuerzo negativo: se retira una consecuencia aversiva y la conducta aumenta. Castigo negativo: se retira una consecuencia agradable y la conducta disminuye. Por tanto, refuerzo negativo y castigo no son sinónimos.

### Moldeamiento

Consiste en reforzar aproximaciones sucesivas a la conducta objetivo. En lugar de exigir desde el principio una ejecución completa, se reconocen pasos cada vez más cercanos al objetivo. Es un concepto de aprendizaje, no una prescripción automática de ejercicio para cualquier paciente.

### Relación terapéutica

El programa incluye comunicación, obstáculos comunicativos y adherencia. Comprender el comportamiento ayuda a formular preguntas sobre dificultades reales y adaptar la explicación. Se mantiene el respeto por la persona y sus decisiones; conocer un mecanismo de aprendizaje no autoriza a manipularla.

### Aplicación

Si un reconocimiento verbal tras una práctica se acompaña de un aumento de esa conducta, encaja con refuerzo positivo. Para clasificar el mecanismo hay que comprobar qué se añade o retira y cómo cambia la conducta; la intención del profesional no basta.

### Autoevaluación

Construye una tabla de dos criterios: añadir o retirar, aumentar o disminuir. Explica por qué retirar un estímulo no significa siempre castigar.

Material de entrenamiento original, no examen oficial.',updated_at=now() WHERE id='b7301030-2026-4000-8002-000000000001' AND (content='### Objetivos de repaso
Distinguir aprendizaje por asociación de estímulos y aprendizaje por consecuencias; utilizar correctamente refuerzo positivo, refuerzo negativo y castigo. Este bloque complementa los modelos y la comunicación del programa de Psicología.

### Dos formas de aprendizaje
En el condicionamiento clásico se aprende una relación entre estímulos. Un estímulo inicialmente neutro, después de asociarse con otro que provoca una respuesta, puede terminar desencadenando una respuesta aprendida.
En el condicionamiento operante se relaciona una conducta con sus consecuencias: estas pueden aumentar o disminuir su probabilidad futura.

### Vocabulario del condicionamiento clásico
El estímulo incondicionado desencadena una respuesta sin aprendizaje previo. La respuesta incondicionada es esa reacción no aprendida. El estímulo condicionado adquiere su efecto mediante la asociación; la respuesta condicionada es la respuesta aprendida.
No confundas estímulo, que se presenta, con respuesta, que hace el organismo. Una reacción anticipatoria aprendida no demuestra por sí sola una nueva lesión.

### Refuerzo y castigo
Refuerzo significa que aumenta la probabilidad de una conducta. Castigo significa que disminuye. Positivo indica que se añade un estímulo; negativo, que se retira. Estas palabras no equivalen a bueno y malo.
Refuerzo positivo: se añade una consecuencia y la conducta aumenta. Refuerzo negativo: se retira una consecuencia aversiva y la conducta aumenta. Castigo negativo: se retira una consecuencia agradable y la conducta disminuye. Por tanto, refuerzo negativo y castigo no son sinónimos.

### Moldeamiento
Consiste en reforzar aproximaciones sucesivas a la conducta objetivo. En lugar de exigir desde el principio una ejecución completa, se reconocen pasos cada vez más cercanos al objetivo. Es un concepto de aprendizaje, no una prescripción automática de ejercicio para cualquier paciente.

### Relación terapéutica
El programa incluye comunicación, obstáculos comunicativos y adherencia. Comprender el comportamiento ayuda a formular preguntas sobre dificultades reales y adaptar la explicación. Se mantiene el respeto por la persona y sus decisiones; conocer un mecanismo de aprendizaje no autoriza a manipularla.

### Aplicación
Si un reconocimiento verbal tras una práctica se acompaña de un aumento de esa conducta, encaja con refuerzo positivo. Para clasificar el mecanismo hay que comprobar qué se añade o retira y cómo cambia la conducta; la intención del profesional no basta.

### Autoevaluación
Construye una tabla de dos criterios: añadir o retirar, aumentar o disminuir. Explica por qué retirar un estímulo no significa siempre castigar.

Material de entrenamiento original, no examen oficial.' OR content='### Objetivos de repaso

Distinguir aprendizaje por asociación de estímulos y aprendizaje por consecuencias; utilizar correctamente refuerzo positivo, refuerzo negativo y castigo. Este bloque complementa los modelos y la comunicación del programa de Psicología.

### Dos formas de aprendizaje

En el condicionamiento clásico se aprende una relación entre estímulos. Un estímulo inicialmente neutro, después de asociarse con otro que provoca una respuesta, puede terminar desencadenando una respuesta aprendida.
En el condicionamiento operante se relaciona una conducta con sus consecuencias: estas pueden aumentar o disminuir su probabilidad futura.

### Vocabulario del condicionamiento clásico

El estímulo incondicionado desencadena una respuesta sin aprendizaje previo. La respuesta incondicionada es esa reacción no aprendida. El estímulo condicionado adquiere su efecto mediante la asociación; la respuesta condicionada es la respuesta aprendida.
No confundas estímulo, que se presenta, con respuesta, que hace el organismo. Una reacción anticipatoria aprendida no demuestra por sí sola una nueva lesión.

### Refuerzo y castigo

Refuerzo significa que aumenta la probabilidad de una conducta. Castigo significa que disminuye. Positivo indica que se añade un estímulo; negativo, que se retira. Estas palabras no equivalen a bueno y malo.
Refuerzo positivo: se añade una consecuencia y la conducta aumenta. Refuerzo negativo: se retira una consecuencia aversiva y la conducta aumenta. Castigo negativo: se retira una consecuencia agradable y la conducta disminuye. Por tanto, refuerzo negativo y castigo no son sinónimos.

### Moldeamiento

Consiste en reforzar aproximaciones sucesivas a la conducta objetivo. En lugar de exigir desde el principio una ejecución completa, se reconocen pasos cada vez más cercanos al objetivo. Es un concepto de aprendizaje, no una prescripción automática de ejercicio para cualquier paciente.

### Relación terapéutica

El programa incluye comunicación, obstáculos comunicativos y adherencia. Comprender el comportamiento ayuda a formular preguntas sobre dificultades reales y adaptar la explicación. Se mantiene el respeto por la persona y sus decisiones; conocer un mecanismo de aprendizaje no autoriza a manipularla.

### Aplicación

Si un reconocimiento verbal tras una práctica se acompaña de un aumento de esa conducta, encaja con refuerzo positivo. Para clasificar el mecanismo hay que comprobar qué se añade o retira y cómo cambia la conducta; la intención del profesional no basta.

### Autoevaluación

Construye una tabla de dos criterios: añadir o retirar, aumentar o disminuir. Explica por qué retirar un estímulo no significa siempre castigar.

Material de entrenamiento original, no examen oficial.');
UPDATE public.curriculum_lessons SET content='### Objetivos de repaso

Reconocer determinantes sociales de la salud, analizar barreras de acceso y comprender la diversidad sin convertirla en estereotipos. Este bloque desarrolla contenidos de desigualdad y comunicación intercultural.

### Salud y condiciones de vida

Los determinantes sociales son las condiciones en que las personas nacen, crecen, viven, trabajan y envejecen, junto con las fuerzas sociales, políticas y económicas que las configuran. Incluyen vivienda, educación, alimentación, trabajo y protección social. La atención sanitaria importa, pero no agota las causas de la salud.

### Gradiente social

Las diferencias de salud no se limitan a una separación entre pobreza extrema y el resto de la población. El gradiente social describe una relación progresiva entre desventaja social y peores resultados de salud. Es una relación poblacional; no permite predecir con certeza la salud de cada individuo.

### Desigualdad y equidad

Describir una diferencia es un primer paso. Analizar la equidad exige preguntarse por la distribución de recursos, oportunidades y barreras. Ofrecer exactamente el mismo recurso puede dejar sin acceso a quienes encuentran obstáculos distintos. Mejorar el acceso puede requerir respuestas adaptadas al contexto.

### Diversidad y comunicación

La antropología de la salud estudia las creencias y prácticas relacionadas con salud, enfermedad y cuidados dentro de su contexto. Una nacionalidad no determina por sí sola lo que cree una persona. Conviene explorar cómo entiende su problema, qué espera de la atención y qué dificultades comunicativas existen, con respeto y sin suposiciones.

### Género, estigma y discriminación

El programa incluye estas dimensiones porque pueden influir en experiencias y oportunidades. Un análisis respetuoso evita culpar a un colectivo y examina barreras y relaciones sociales. La participación de la persona en la atención ayuda a comprender su situación concreta.

### Aplicación en fisioterapia

Una persona no acude porque sus turnos laborales y el transporte dificultan la asistencia. Antes de atribuirlo a falta de interés, se exploran esas barreras y las opciones de coordinación. Una vivienda inadecuada o la dificultad para costear desplazamientos también pueden condicionar el seguimiento.

### Autoevaluación

Separa en un caso lo observado de lo supuesto. Identifica una barrera social, una pregunta para comprenderla y una posible adaptación que deba discutirse con la persona y el equipo.

Material original de entrenamiento basado en UVic y OMS; no es un examen oficial.',updated_at=now() WHERE id='b7301030-2026-4000-8002-000000000002' AND (content='### Objetivos de repaso
Reconocer determinantes sociales de la salud, analizar barreras de acceso y comprender la diversidad sin convertirla en estereotipos. Este bloque desarrolla contenidos de desigualdad y comunicación intercultural.

### Salud y condiciones de vida
Los determinantes sociales son las condiciones en que las personas nacen, crecen, viven, trabajan y envejecen, junto con las fuerzas sociales, políticas y económicas que las configuran. Incluyen vivienda, educación, alimentación, trabajo y protección social. La atención sanitaria importa, pero no agota las causas de la salud.

### Gradiente social
Las diferencias de salud no se limitan a una separación entre pobreza extrema y el resto de la población. El gradiente social describe una relación progresiva entre desventaja social y peores resultados de salud. Es una relación poblacional; no permite predecir con certeza la salud de cada individuo.

### Desigualdad y equidad
Describir una diferencia es un primer paso. Analizar la equidad exige preguntarse por la distribución de recursos, oportunidades y barreras. Ofrecer exactamente el mismo recurso puede dejar sin acceso a quienes encuentran obstáculos distintos. Mejorar el acceso puede requerir respuestas adaptadas al contexto.

### Diversidad y comunicación
La antropología de la salud estudia las creencias y prácticas relacionadas con salud, enfermedad y cuidados dentro de su contexto. Una nacionalidad no determina por sí sola lo que cree una persona. Conviene explorar cómo entiende su problema, qué espera de la atención y qué dificultades comunicativas existen, con respeto y sin suposiciones.

### Género, estigma y discriminación
El programa incluye estas dimensiones porque pueden influir en experiencias y oportunidades. Un análisis respetuoso evita culpar a un colectivo y examina barreras y relaciones sociales. La participación de la persona en la atención ayuda a comprender su situación concreta.

### Aplicación en fisioterapia
Una persona no acude porque sus turnos laborales y el transporte dificultan la asistencia. Antes de atribuirlo a falta de interés, se exploran esas barreras y las opciones de coordinación. Una vivienda inadecuada o la dificultad para costear desplazamientos también pueden condicionar el seguimiento.

### Autoevaluación
Separa en un caso lo observado de lo supuesto. Identifica una barrera social, una pregunta para comprenderla y una posible adaptación que deba discutirse con la persona y el equipo.

Material original de entrenamiento basado en UVic y OMS; no es un examen oficial.' OR content='### Objetivos de repaso

Reconocer determinantes sociales de la salud, analizar barreras de acceso y comprender la diversidad sin convertirla en estereotipos. Este bloque desarrolla contenidos de desigualdad y comunicación intercultural.

### Salud y condiciones de vida

Los determinantes sociales son las condiciones en que las personas nacen, crecen, viven, trabajan y envejecen, junto con las fuerzas sociales, políticas y económicas que las configuran. Incluyen vivienda, educación, alimentación, trabajo y protección social. La atención sanitaria importa, pero no agota las causas de la salud.

### Gradiente social

Las diferencias de salud no se limitan a una separación entre pobreza extrema y el resto de la población. El gradiente social describe una relación progresiva entre desventaja social y peores resultados de salud. Es una relación poblacional; no permite predecir con certeza la salud de cada individuo.

### Desigualdad y equidad

Describir una diferencia es un primer paso. Analizar la equidad exige preguntarse por la distribución de recursos, oportunidades y barreras. Ofrecer exactamente el mismo recurso puede dejar sin acceso a quienes encuentran obstáculos distintos. Mejorar el acceso puede requerir respuestas adaptadas al contexto.

### Diversidad y comunicación

La antropología de la salud estudia las creencias y prácticas relacionadas con salud, enfermedad y cuidados dentro de su contexto. Una nacionalidad no determina por sí sola lo que cree una persona. Conviene explorar cómo entiende su problema, qué espera de la atención y qué dificultades comunicativas existen, con respeto y sin suposiciones.

### Género, estigma y discriminación

El programa incluye estas dimensiones porque pueden influir en experiencias y oportunidades. Un análisis respetuoso evita culpar a un colectivo y examina barreras y relaciones sociales. La participación de la persona en la atención ayuda a comprender su situación concreta.

### Aplicación en fisioterapia

Una persona no acude porque sus turnos laborales y el transporte dificultan la asistencia. Antes de atribuirlo a falta de interés, se exploran esas barreras y las opciones de coordinación. Una vivienda inadecuada o la dificultad para costear desplazamientos también pueden condicionar el seguimiento.

### Autoevaluación

Separa en un caso lo observado de lo supuesto. Identifica una barrera social, una pregunta para comprenderla y una posible adaptación que deba discutirse con la persona y el equipo.

Material original de entrenamiento basado en UVic y OMS; no es un examen oficial.');
UPDATE public.curriculum_quiz_questions SET question_text='Caso profesional — Una situación supera claramente el ámbito de actuación del estudiante. ¿Qué conducta es la más segura?',explanation='Reconocer los límites de actuación y solicitar ayuda forma parte de una práctica segura.',options='[{"text":"Reconocer el límite y pedir supervisión","correct":true},{"text":"Improvisar una intervención no dominada","correct":false},{"text":"Ocultar la dificultad al supervisor","correct":false},{"text":"Actuar sin informar al paciente","correct":false}]'::jsonb,source_label='Entrenamiento original · https://www.uvic.cat/es/assignatura/4412',metadata=metadata||'{"language_revision":"es-s1-suite-20261030","language":"es","source_urls":["https://www.uvic.cat/es/assignatura/4412"]}'::jsonb,updated_at=now() WHERE id='9ddd8f72-fdde-46bb-930f-2f1498e8f956' AND (question_text='Caso profesional — Una situación dépasse clairement le ámbito de actuación del estudiante. ¿Qué conducta es la más segura?' OR question_text='Caso profesional — Una situación supera claramente el ámbito de actuación del estudiante. ¿Qué conducta es la más segura?');
UPDATE public.curriculum_quiz_questions SET question_text='¿Qué combinación describe mejor una práctica profesional respetuosa?',explanation='Una práctica respetuosa combina competencia, información comprensible, consentimiento y respeto de la autonomía.',options='[{"text":"Información comprensible + consentimiento + respeto de la autonomía","correct":true},{"text":"Técnica impuesta sin explicación","correct":false},{"text":"Decisión sin participación del paciente","correct":false},{"text":"Intervención fuera de las propias competencias","correct":false}]'::jsonb,source_label='Entrenamiento original · https://www.uvic.cat/es/assignatura/4412',metadata=metadata||'{"language_revision":"es-s1-suite-20261030","language":"es","source_urls":["https://www.uvic.cat/es/assignatura/4412"]}'::jsonb,updated_at=now() WHERE id='e4b0d8b5-cfa9-4d2a-99ca-0619e8f520c5' AND (question_text='¿Qué combinaison décrit le mieux une pratique professionnelle respectueuse?' OR question_text='¿Qué combinación describe mejor una práctica profesional respetuosa?');
DO $test$ BEGIN
IF (SELECT count(*) FROM public.curriculum_quiz_questions WHERE metadata->>'content_batch'='es-s1-suite-20261030' AND is_published)<>60 THEN RAISE EXCEPTION 'Expected 60 questions'; END IF;
IF EXISTS(SELECT 1 FROM public.curriculum_quiz_questions q WHERE metadata->>'content_batch'='es-s1-suite-20261030' AND (jsonb_array_length(options)<>4 OR (SELECT count(*) FROM jsonb_array_elements(options) x WHERE (x->>'correct')::boolean)<>1 OR length(explanation)<30 OR source_label NOT LIKE '%https://%')) THEN RAISE EXCEPTION 'Invalid question'; END IF;
IF EXISTS(SELECT 1 FROM public.curriculum_quiz_questions n JOIN public.curriculum_quiz_questions o ON lower(trim(n.question_text))=lower(trim(o.question_text)) AND n.id<>o.id WHERE n.metadata->>'content_batch'='es-s1-suite-20261030') THEN RAISE EXCEPTION 'Duplicate question'; END IF;
END $test$;
DO $test$ BEGIN IF NOT EXISTS(SELECT 1 FROM public.curriculum_lessons WHERE id='c7301030-2026-4000-8002-000000000001' AND content='### Lo que debes comprender

La homeostasis mantiene condiciones internas dentro de un intervalo compatible con el funcionamiento del organismo. No significa ausencia de cambios: las variables fluctúan y se regulan continuamente. El punto de ajuste sirve como referencia, pero no obliga a que una variable tenga un valor idéntico en todo momento.

### Un circuito de regulación

El receptor o sensor detecta una variable. El centro de control compara la información con la referencia y organiza una respuesta. El efector ejecuta el cambio. Para entender un ejemplo, separa qué se mide, quién interpreta la señal y quién actúa. Una misma estructura puede reunir más de una función; el esquema es funcional.

### Retroalimentación negativa

La respuesta contrarresta la desviación inicial. Si aumenta la temperatura corporal, las respuestas que facilitan la pérdida de calor contribuyen a limitar ese aumento. La vasodilatación cutánea favorece la transferencia de calor hacia la superficie; la evaporación del sudor permite perder calor. Ante el frío, el temblor muscular produce calor.
Negativa no significa perjudicial: describe la dirección de la respuesta respecto al cambio inicial.

### Retroalimentación positiva

La respuesta amplifica el cambio inicial. En el parto, el estiramiento cervical favorece la liberación de oxitocina, que aumenta las contracciones y el estiramiento. El nacimiento interrumpe el circuito. Es un proceso con un final definido; no es el mecanismo general para estabilizar todas las variables.

### Aprende a razonar

Un aumento inicial seguido de una respuesta que reduce ese aumento indica retroalimentación negativa. Si la respuesta intensifica el proceso inicial, piensa en positiva. El nombre no informa por sí solo de si un proceso es saludable o patológico.

### Errores frecuentes

Confundir efector con sensor; definir homeostasis como inmovilidad; interpretar positivo como beneficioso y negativo como dañino.

### Cómo comprobarlo

Cierra la ficha, explica los puntos clave con tus palabras y responde al cuestionario. Para cada error, identifica el concepto confundido y vuelve a la explicación antes de repetir.

Material original de entrenamiento basado en las fuentes enlazadas. No es un examen ni un apunte oficial de UVic.' AND is_published AND jsonb_array_length(source_files)>0) THEN RAISE EXCEPTION 'Lesson content mismatch'; END IF; END $test$;
DO $test$ BEGIN IF NOT EXISTS(SELECT 1 FROM public.curriculum_lessons WHERE id='c7301030-2026-4000-8002-000000000002' AND content='### Objetivo

Poder seguir una gota de sangre a través de los circuitos pulmonar y sistémico, identificando cavidades y válvulas sin depender de colores de un dibujo.

### Localización y cavidades

El corazón está en el mediastino, entre los pulmones. Tiene dos aurículas y dos ventrículos. Las aurículas reciben sangre; los ventrículos la impulsan hacia los circuitos. El miocardio es la capa muscular de la pared cardíaca. El pericardio envuelve el corazón.

### Recorrido completo

La sangre de la circulación sistémica regresa por las venas cavas a la aurícula derecha. Pasa por la válvula tricúspide al ventrículo derecho, atraviesa la válvula pulmonar y sale por el tronco pulmonar hacia los pulmones.
Tras el intercambio pulmonar, vuelve por las venas pulmonares a la aurícula izquierda. Cruza la válvula mitral o bicúspide hacia el ventrículo izquierdo y sale, a través de la válvula aórtica, hacia la aorta y la circulación sistémica.

### Arterias y venas

Una arteria conduce sangre desde el corazón; una vena la devuelve hacia él. El criterio es la dirección, no la cantidad de oxígeno. En la circulación pulmonar del adulto, las arterias llevan sangre relativamente pobre en oxígeno y las venas sangre rica en oxígeno. Por eso no conviene memorizar «arteria equivale a sangre oxigenada».

### Válvulas y pared

Las válvulas favorecen el flujo unidireccional y evitan el retroceso. Tricúspide y mitral son auriculoventriculares; pulmonar y aórtica son semilunares. El ventrículo izquierdo tiene una pared muscular más gruesa porque impulsa sangre al circuito sistémico, que requiere mayor presión.

### Práctica sin mirar

Recita el recorrido desde las cavas hasta la aorta e identifica dónde cambian los contenidos de oxígeno y dióxido de carbono. En un esquema, comprueba si la derecha corresponde al paciente o a quien observa.

### Cómo comprobarlo

Cierra la ficha, explica los puntos clave con tus palabras y responde al cuestionario. Para cada error, identifica el concepto confundido y vuelve a la explicación antes de repetir.

Material original de entrenamiento basado en las fuentes enlazadas. No es un examen ni un apunte oficial de UVic.' AND is_published AND jsonb_array_length(source_files)>0) THEN RAISE EXCEPTION 'Lesson content mismatch'; END IF; END $test$;
DO $test$ BEGIN IF NOT EXISTS(SELECT 1 FROM public.curriculum_lessons WHERE id='c7301030-2026-4000-8002-000000000003' AND content='### Objetivo

Separar las estructuras que conducen el aire de las que participan directamente en el intercambio gaseoso.

### Recorrido del aire

Desde las cavidades nasales, el aire pasa por faringe, laringe, tráquea, bronquios y bronquiolos. Los bronquiolos terminales pertenecen a la zona de conducción. Después aparecen bronquiolos respiratorios, conductos alveolares y alvéolos, que forman parte de la zona respiratoria.

### Zona de conducción

Proporciona una vía de entrada y salida del aire y contribuye a filtrarlo, calentarlo y humidificarlo. La tráquea no es el principal lugar de intercambio de oxígeno con la sangre.
En buena parte de las vías de conducción, el moco atrapa partículas y los cilios contribuyen a transportarlo hacia la faringe. Moco y cilios cumplen funciones complementarias: uno retiene material y los otros lo movilizan. Los cilios no producen por sí solos el moco.

### Faringe y laringe

La faringe tiene porciones nasofaríngea, orofaríngea y laringofaríngea. La orofaringe es una vía compartida por aire y alimentos. La laringe conecta la faringe con la tráquea y participa en la producción de la voz. No debe confundirse con el esófago, que pertenece a la vía digestiva.

### Alvéolos

Los alvéolos ofrecen una superficie especializada para el intercambio con los capilares. Los neumocitos de tipo I, delgados, participan en la barrera de intercambio. Los de tipo II producen surfactante, que reduce la tensión superficial. Los macrófagos alveolares participan en la defensa mediante fagocitosis.
Ventilar es mover aire; intercambiar gases es transferirlos entre aire alveolar y sangre. Son procesos relacionados, pero diferentes.

### Caso para razonar

Si una pregunta sitúa el intercambio gaseoso en la tráquea, identifica el error de localización antes de responder. Para explicar una función, vincula siempre estructura y tarea.

### Errores frecuentes

Confundir bronquiolo terminal con respiratorio; atribuir el moco a los cilios; confundir ventilación con intercambio.

### Cómo comprobarlo

Cierra la ficha, explica los puntos clave con tus palabras y responde al cuestionario. Para cada error, identifica el concepto confundido y vuelve a la explicación antes de repetir.

Material original de entrenamiento basado en las fuentes enlazadas. No es un examen ni un apunte oficial de UVic.' AND is_published AND jsonb_array_length(source_files)>0) THEN RAISE EXCEPTION 'Lesson content mismatch'; END IF; END $test$;
DO $test$ BEGIN IF NOT EXISTS(SELECT 1 FROM public.curriculum_lessons WHERE id='c7301030-2026-4000-8002-000000000004' AND content='### Objetivo

Distinguir los componentes de la sangre y justificar su función. Este bloque es introductorio: los grupos sanguíneos, la hematopoyesis y la cascada de coagulación requieren estudio adicional.

### Un tejido conectivo líquido

La sangre incluye elementos formes suspendidos en una matriz extracelular líquida: el plasma. Los elementos formes son eritrocitos, leucocitos y plaquetas; estas últimas son fragmentos celulares, no células completas equivalentes a los leucocitos.

### Transporte y defensa

La sangre transporta gases, nutrientes, hormonas y productos de desecho. Los eritrocitos contienen hemoglobina, relacionada con el transporte de oxígeno. Los leucocitos participan en la defensa; no deben confundirse con plaquetas. Las plaquetas y proteínas plasmáticas colaboran en la hemostasia para limitar la pérdida de sangre tras una lesión vascular.

### Plasma y proteínas

El plasma está compuesto principalmente por agua con proteínas y otros solutos. La albúmina contribuye a la presión osmótica plasmática y transporta determinadas sustancias. Las inmunoglobulinas participan en la inmunidad. El fibrinógeno interviene en la coagulación.
El suero es el líquido obtenido después de la coagulación y carece de fibrinógeno funcional disponible como en el plasma. No es equivalente a sangre total.

### Hematocrito

Expresa la fracción del volumen sanguíneo ocupada por eritrocitos. No indica la proporción de leucocitos ni es el mismo dato que la concentración de hemoglobina. En una muestra centrifugada, los eritrocitos se sitúan abajo, el plasma arriba y una capa fina intermedia contiene leucocitos y plaquetas.

### Homeostasis

La sangre contribuye a distribuir calor, regular el equilibrio químico y transportar sustancias entre órganos. Una misma función global puede depender de varios componentes: hemostasia no significa «solo plaquetas» e inmunidad no significa «solo un tipo de célula».

### Errores frecuentes

Llamar plasma a toda la sangre; confundir plaquetas con leucocitos; interpretar hematocrito como porcentaje de hemoglobina.

### Cómo comprobarlo

Cierra la ficha y explica los puntos clave con tus palabras. Responde al cuestionario y, en cada error, identifica qué concepto has confundido antes de repetir.

Material original de entrenamiento basado en las fuentes enlazadas; no es un examen oficial de UVic.' AND is_published AND jsonb_array_length(source_files)>0) THEN RAISE EXCEPTION 'Lesson content mismatch'; END IF; END $test$;
DO $test$ BEGIN IF NOT EXISTS(SELECT 1 FROM public.curriculum_lessons WHERE id='c7301030-2026-4000-8002-000000000005' AND content='### Objetivo

Utilizar la CIF como lenguaje para describir funcionamiento y discapacidad sin reducir la valoración a un diagnóstico médico.

### Componentes básicos

Las funciones corporales son las funciones fisiológicas de los sistemas, incluidas las psicológicas. Las estructuras corporales son partes anatómicas, como órganos y miembros. Una deficiencia es un problema significativo de función o estructura.
Actividad significa ejecutar una tarea o acción. Participación significa implicarse en una situación de la vida. Dificultad para realizar una tarea es limitación de actividad; un problema para implicarse en una situación vital es restricción de participación. En casos reales, actividad y participación están relacionadas y su distinción exige explicar qué aspecto se describe.

### Capacidad y desempeño

El desempeño describe lo que la persona hace en su entorno actual. La capacidad valora la aptitud para ejecutar una tarea en un entorno uniforme o estandarizado. Deben especificarse las condiciones y las ayudas: una prueba en consulta no describe automáticamente toda la vida diaria.
Si alguien camina en un pasillo accesible, pero no puede llegar a su vivienda por escaleras, hay que investigar esa diferencia y el contexto.

### Factores ambientales

El entorno físico, social y actitudinal puede facilitar o dificultar el funcionamiento. Una rampa, una ayuda técnica o apoyo de otras personas pueden facilitar una actividad. Escaleras inaccesibles o actitudes discriminatorias pueden actuar como barreras. Un mismo elemento puede tener efectos diferentes según la persona y la situación.

### Análisis paso a paso

En un caso separa: qué función o estructura está afectada, qué tarea presenta dificultades, qué situación vital importa a la persona y qué factores del entorno intervienen. No deduzcas automáticamente un grado de discapacidad a partir del nombre de una enfermedad.

### Ejemplo

Una persona presenta dolor, dificultad para caminar y ausencia del trabajo por problemas para acceder al edificio. Dolor, marcha y participación laboral son dimensiones diferentes; el acceso al edificio aporta información ambiental. Registrar solo dolor deja una parte importante sin describir.

### Errores frecuentes

Confundir actividad con estructura; omitir funciones psicológicas; suponer que diagnóstico y funcionamiento son equivalentes.

### Cómo comprobarlo

Cierra la ficha y explica los puntos clave con tus palabras. Responde al cuestionario y, en cada error, identifica qué concepto has confundido antes de repetir.

Material original de entrenamiento basado en las fuentes enlazadas; no es un examen oficial de UVic.' AND is_published AND jsonb_array_length(source_files)>0) THEN RAISE EXCEPTION 'Lesson content mismatch'; END IF; END $test$;
DO $test$ BEGIN IF NOT EXISTS(SELECT 1 FROM public.curriculum_lessons WHERE id='c7301030-2026-4000-8002-000000000006' AND content='### Objetivo

Convertir una explicación técnica en una conversación que permita comprender opciones y decidir con la persona.

### Antes de explicar

Explora qué le importa, qué espera y qué preguntas desea resolver. Al inicio, acordad los asuntos prioritarios y el tiempo disponible. La información debe adaptarse al contexto y a las necesidades de accesibilidad. No se presupone que todas las personas quieran o puedan participar de la misma manera.

### Información por partes

Presenta pequeñas unidades de información y comprueba la comprensión antes de avanzar. Explicar muchas instrucciones seguidas puede dificultar saber qué se ha entendido.
La comprobación mediante reformulación, o teach-back, consiste en invitar a explicar con palabras propias lo tratado. Evalúa la claridad de la explicación, no el valor ni la inteligencia de la persona. «¿Ha entendido?» puede obtener un sí sin mostrar qué se ha comprendido.

### Opciones y preferencias

Comenta objetivos, beneficios, riesgos y consecuencias de las opciones pertinentes. La conversación también puede incluir no cambiar el tratamiento o no intervenir, según la situación. Las preferencias del profesional no sustituyen a las del paciente. Hay que reconocer incertidumbres y dejar tiempo para preguntas.
Una ayuda de decisión apoya la conversación; no la reemplaza ni debe imponer una opción.

### Apoyos

Pregunta si la persona desea implicar a familiares, amistades o personas de apoyo. Su presencia no se da por supuesta. Cuando existen dificultades para comprender o participar, se puede valorar apoyo adicional, por ejemplo interpretación o formatos accesibles.

### Cierre y seguimiento

Resume qué se ha acordado, qué ocurrirá después y cuándo se revisará. Registra las decisiones y los aspectos importantes para la persona. Explica cómo plantear nuevas dudas y que la decisión puede revisarse.

### Simulación de práctica

En parejas, una persona explica dos opciones y la otra reformula lo entendido. Quien explica identifica qué debe aclarar y ambos acuerdan el siguiente paso.

Estas recomendaciones se usan como referencia de comunicación clínica; NICE es una fuente británica, no una norma jurídica española.

### Cómo comprobarlo

Cierra la ficha y explica los puntos clave con tus palabras. Responde al cuestionario y, en cada error, identifica qué concepto has confundido antes de repetir.

Material original de entrenamiento basado en las fuentes enlazadas; no es un examen oficial de UVic.' AND is_published AND jsonb_array_length(source_files)>0) THEN RAISE EXCEPTION 'Lesson content mismatch'; END IF; END $test$;
DO $test$ BEGIN IF NOT EXISTS(SELECT 1 FROM public.curriculum_lessons WHERE id='c7301030-2026-4000-8002-000000000007' AND content='### Una sesión posible

Esta distribución es una propuesta práctica, no una duración óptima demostrada para todos.
- Elige un bloque y revisa sus objetivos.
- Lee la ficha y relaciona cada concepto con un ejemplo.
- Cierra el texto e intenta explicarlo sin mirar.
- Haz el cuestionario antes de consultar la corrección.
- Comprueba por qué la opción correcta lo es y por qué tu elección falla.
- Anota una regla breve o una comparación que evite repetir el error.

### Repasar en varios días

Distribuye las sesiones en el tiempo en lugar de concentrar todo el estudio en una sola jornada. Como ejemplo adaptable, vuelve al bloque al día siguiente, unos días después y la semana siguiente. Estos intervalos son una propuesta organizativa, no una configuración automática de la aplicación.

### Tres categorías para tus errores

- No lo sabía: vuelve al concepto y crea una pregunta breve.
- Confundí dos ideas: escribe la diferencia y un ejemplo de cada una.
- Leí mal: identifica la palabra que cambió el sentido y relee todas las opciones.

### Responder bien no siempre significa dominar

Tras acertar, intenta justificar la respuesta sin mirar. Reconocer una frase no equivale siempre a poder recuperarla y explicarla. Revisa los fallos con mayor frecuencia, pero vuelve también a contenidos ya acertados.

### Un orden orientativo

Empieza por organización y tejidos; después membrana y transporte, homeostasis, sangre, corazón y aparato respiratorio. Alterna con CIF, fundamentos, psicología y cultura. Es una propuesta de recorrido por los bloques disponibles; no reemplaza el calendario docente ni significa que todo el semestre esté cubierto.

### Cuidar el entorno de estudio

Reduce interrupciones y evita estudiar con varias fuentes de distracción a la vez. Reserva descanso suficiente: el sueño participa en la consolidación de la memoria. Una regla mnemotécnica puede ayudar a recordar una lista, pero comprueba que también entiendes su significado.

### Antes de una evaluación

Usa el programa del profesor para comprobar qué falta. Estas fichas y preguntas son material complementario de entrenamiento, no exámenes oficiales ni una predicción del examen.' AND is_published AND jsonb_array_length(source_files)>0) THEN RAISE EXCEPTION 'Lesson content mismatch'; END IF; END $test$;
DO $test$ BEGIN IF NOT EXISTS(SELECT 1 FROM public.curriculum_lessons WHERE id='21afcaf4-82c8-4ea6-8778-dd0ee108ec6b' AND content='### Objetivos de repaso

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

Material de entrenamiento original basado en fuentes; no es un examen oficial.') THEN RAISE EXCEPTION 'Formatting conflict'; END IF; END $test$;
DO $test$ BEGIN IF NOT EXISTS(SELECT 1 FROM public.curriculum_lessons WHERE id='3bd5d230-90e8-4e09-9487-b7a75accb5a2' AND content='Fisiología II introduce conceptos de neurociencia relevantes para comprender el movimiento y la función. La neuroplasticidad describe la capacidad del sistema nervioso para modificar su organización y funcionamiento en respuesta a la experiencia y al aprendizaje.

El sistema somatosensorial aporta información sobre el cuerpo, mientras que los sistemas visual y vestibular también participan en la orientación y el control postural. El control motor integra información sensorial y órdenes motoras para producir movimientos adaptados.

El aprendizaje motor, la atención y la memoria influyen en la adquisición y repetición de habilidades. Estos conceptos ayudan a comprender por qué la práctica, la retroalimentación y el contexto son importantes durante la rehabilitación.

En rehabilitación, la práctica repetida cobra sentido cuando el paciente recibe información útil sobre el resultado y la ejecución. El feedback permite ajustar el movimiento, mientras que la repetición en contextos variados favorece el aprendizaje y la transferencia a tareas funcionales. La dificultad debe progresar sin perder seguridad ni calidad de movimiento.') THEN RAISE EXCEPTION 'Formatting conflict'; END IF; END $test$;
DO $test$ BEGIN IF NOT EXISTS(SELECT 1 FROM public.curriculum_lessons WHERE id='7e9e37d5-20fa-49fc-bbbf-aee1bc790db5' AND content='La historia clínica organiza la información relevante de la persona: motivo de consulta, antecedentes, síntomas, evolución y repercusión funcional. La entrevista clínica permite completar esta información mediante preguntas claras y dirigidas.

La semiología ayuda a describir signos y síntomas de forma ordenada. En fisioterapia, esta información se relaciona con la valoración de las capacidades funcionales y con el análisis del movimiento y de la actividad.

El diagnóstico funcional de fisioterapia sintetiza los hallazgos relevantes para orientar los objetivos de intervención. No consiste únicamente en nombrar una patología, sino en comprender cómo la situación afecta a la función.

### Approfondissement

Una buena historia clínica no es una lista de datos aislados. Debe organizar la información relevante, relacionar síntomas y evolución con el impacto funcional y orientar la exploración. El diagnóstico funcional sintetiza lo que la persona puede o no puede hacer, qué factores lo limitan y qué objetivos de fisioterapia son prioritarios.') THEN RAISE EXCEPTION 'Formatting conflict'; END IF; END $test$;
DO $test$ BEGIN IF NOT EXISTS(SELECT 1 FROM public.curriculum_lessons WHERE id='ab7d1b48-00b2-45f3-97ae-c055c7a6a0e0' AND content='### Objetivos de repaso

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

Ejercicios originales de entrenamiento; no son preguntas de examen autenticadas.') THEN RAISE EXCEPTION 'Formatting conflict'; END IF; END $test$;
DO $test$ BEGIN IF NOT EXISTS(SELECT 1 FROM public.curriculum_lessons WHERE id='3d6bb405-866f-4daf-acb9-618bd8cc2100' AND content='El ejercicio terapéutico utiliza movimientos y actividades planificadas con un objetivo funcional. No se trata simplemente de hacer ejercicio: en fisioterapia, cada propuesta debe relacionarse con una capacidad que se quiere mantener, recuperar o mejorar.

La planificación tiene en cuenta las capacidades físicas básicas y la respuesta de la persona al esfuerzo. La progresión debe ser gradual y coherente con el nivel funcional observado.

La prescripción forma parte de la intervención fisioterapéutica. El estudiante debe aprender a relacionar el ejercicio elegido con un objetivo concreto, observar la tolerancia y adaptar la dificultad cuando sea necesario.

### Approfondissement

Un ejercicio terapéutico debe tener un objetivo observable. Por ejemplo, mejorar la capacidad de levantarse de una silla no exige el mismo trabajo que mejorar el equilibrio o la movilidad de hombro. La progresión puede modificarse aumentando repeticiones, resistencia, amplitud o complejidad, siempre observando la tolerancia. La respuesta del paciente sirve para decidir si mantener, facilitar o aumentar la dificultad.') THEN RAISE EXCEPTION 'Formatting conflict'; END IF; END $test$;
DO $test$ BEGIN IF NOT EXISTS(SELECT 1 FROM public.curriculum_lessons WHERE id='502486f5-ff65-4a23-82fe-40d4408de8d1' AND content='### Objetivos de repaso

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

Material de repaso original basado en las fuentes enlazadas; no es una reproducción del curso ni un examen oficial.') THEN RAISE EXCEPTION 'Formatting conflict'; END IF; END $test$;
DO $test$ BEGIN IF NOT EXISTS(SELECT 1 FROM public.curriculum_lessons WHERE id='865fe31e-5a66-4b18-a370-9273f660c296' AND content='Comprender al paciente exige identificar el vocabulario de dolor y función sin interpretar automáticamente un diagnóstico. Frases como «Me duele la cadera cuando camino» o «No puedo apoyar bien la pierna» describen una molestia y una limitation funcional concreta.

También son frecuentes expresiones como «Tengo rigidez por la mañana» o «El dolor mejora cuando descanso». El estudiante debe repérer douleur, appui, raideur, marche et repos dans leur contexte clinique.

L’objectif est de comprendre ce que le patient exprime, puis de savoir reformuler l’information avant toute interprétation clinique.

### Cómo analizar el mensaje

Primero se identifica el síntoma expresado por el paciente, después la actividad afectada y por último el factor que modifica la molestia. “Me duele la cadera cuando camino” contiene dolor + localización + actividad; “no puedo apoyar bien la pierna” señala una limitación funcional. Esta lectura por bloques ayuda a reformular con precisión sin transformar automáticamente la plainte en diagnostic.') THEN RAISE EXCEPTION 'Formatting conflict'; END IF; END $test$;
DO $test$ BEGIN IF NOT EXISTS(SELECT 1 FROM public.curriculum_lessons WHERE id='ca4270be-ba6e-4442-b152-33c8472f679c' AND content='El rango de movimiento del hombro describe cuánto puede desplazarse la articulación en diferentes direcciones. En la valoración se observa la movilidad y se buscan limitaciones, rigidez o debilidad que puedan interferir con la función.

Los ejercicios pueden dirigirse a estirar y fortalecer los músculos que rodean el hombro y la escápula. El objetivo no es solamente aumentar fuerza, sino favorecer un movimiento más eficaz y funcional.

Durante la práctica, el estudiante debe relacionar movilidad, fuerza y síntomas con actividades concretas del miembro superior, evitando interpretar un dato aislado fuera del conjunto de la valoración.

### Raisonnement simple

Une épaule peut présenter une limitation de mouvement, une faiblesse, une raideur ou une combinaison de ces éléments. L’exercice choisi doit donc être relié à ce qui est observé : étirer lorsqu’un travail de mobilité est recherché, renforcer lorsqu’un déficit de force est identifié, et toujours vérifier le retentissement fonctionnel. Le suivi s’appuie sur l’évolution des symptômes et de la capacité à réaliser les activités du membre supérieur.') THEN RAISE EXCEPTION 'Formatting conflict'; END IF; END $test$;
DO $test$ BEGIN IF NOT EXISTS(SELECT 1 FROM public.curriculum_lessons WHERE id='58a2ea17-3a47-4551-95eb-8be4924678bc' AND content='En la exploración cardio-respiratoria se utilizan varios signos y términos básicos. El pulso permite estimar la frecuencia cardíaca; la frecuencia respiratoria describe el número de respiraciones por minuto; la presión arterial es otro signo vital importante.

Durante el ejercicio o una prueba de esfuerzo también pueden aparecer síntomas relevantes como falta de aire, palpitaciones, mareo o dolor torácico. Reconocer este vocabulario ayuda a comprender las indicaciones y a comunicar síntomas con precisión.

Equivalencias útiles: pulso = pouls, frecuencia cardíaca = fréquence cardiaque, presión arterial = pression artérielle, falta de aire = essoufflement.

### Approfondissement

Para interpretar correctamente una situación cardio-respiratoria, conviene relacionar cada término con una medida o un síntoma concreto. “Pulso” y “frecuencia cardíaca” se refieren al ritmo del corazón; “frecuencia respiratoria” al número de respiraciones por minuto; “presión arterial” a la tensión ejercida por la sangre en las arterias. Durante el esfuerzo, síntomas como falta de aire, palpitaciones, mareo o dolor torácico deben describirse con precisión, indicando cuándo aparecen y si obligan a detener la actividad.') THEN RAISE EXCEPTION 'Formatting conflict'; END IF; END $test$;
DO $test$ BEGIN IF NOT EXISTS(SELECT 1 FROM public.curriculum_lessons WHERE id='77ed1803-59cd-44c7-8d0a-67db4e96d2a7' AND content='El vocabulario neuromotor aparece constantemente en la valoración funcional. Equilibrio describe la capacidad de mantener o recuperar una posición estable; coordinación se refiere a la organización adecuada de los movimientos; sensibilidad permite percibir estímulos procedentes del cuerpo y del entorno.

Marcha significa caminar. Una caída puede relacionarse con problemas de equilibrio, debilidad o alteraciones de la marcha, aunque estos términos por sí solos no establecen un diagnóstico.

En contexto clínico conviene reconocer también nervio, control motor y estabilidad. Dominar estas palabras permite comprender mejor las consignas, la entrevista y las situaciones funcionales descritas por el paciente.

### Aplicación clínica

Ante una queja de inestabilidad, separa equilibrio, coordinación, sensibilidad, fuerza y marcha. Preguntas simples permiten saber si el problema aparece de pie, al caminar, al girar o dans l’obscurité. El objetivo inicial es describir el déficit funcional antes de buscar una explicación causal.') THEN RAISE EXCEPTION 'Formatting conflict'; END IF; END $test$;
DO $test$ BEGIN IF NOT EXISTS(SELECT 1 FROM public.curriculum_lessons WHERE id='599a84b0-9acf-45a1-9cf9-101fa2b2e192' AND content='La muñeca conecta el antebrazo con la mano y permite orientar la mano para las actividades de prensión, apoyo y manipulación. En esta región pasan tendones que movilizan los dedos y también estructuras nerviosas importantes.

El nervio mediano atraviesa el túnel carpiano. Una alteración en esta zona puede modificar la sensibilidad y la función de la mano. Por eso, en fisioterapia es útil relacionar movilidad de muñeca, deslizamiento tendinoso, sensibilidad y capacidad funcional.

Vocabulario útil: muñeca = poignet, mano = main, nervio mediano = nerf médian, tendón = tendon, sensibilidad = sensibilité.

### Relación estructura-función

La muñeca no se estudia de forma aislada de la mano. Una limitación de movilidad puede modificar la orientación de la mano durante la prensión o el apoyo. Del mismo modo, sensibilidad y función deben relacionarse con el trayecto nervioso y con las tareas que la persona tiene dificultad para realizar. En una exploración básica, el estudiante distingue por tanto movilidad, sensibilidad y capacidad funcional antes de sacar conclusiones.') THEN RAISE EXCEPTION 'Formatting conflict'; END IF; END $test$;
DO $test$ BEGIN IF NOT EXISTS(SELECT 1 FROM public.curriculum_lessons WHERE id='b7301030-2026-4000-8002-000000000001' AND content='### Objetivos de repaso

Distinguir aprendizaje por asociación de estímulos y aprendizaje por consecuencias; utilizar correctamente refuerzo positivo, refuerzo negativo y castigo. Este bloque complementa los modelos y la comunicación del programa de Psicología.

### Dos formas de aprendizaje

En el condicionamiento clásico se aprende una relación entre estímulos. Un estímulo inicialmente neutro, después de asociarse con otro que provoca una respuesta, puede terminar desencadenando una respuesta aprendida.
En el condicionamiento operante se relaciona una conducta con sus consecuencias: estas pueden aumentar o disminuir su probabilidad futura.

### Vocabulario del condicionamiento clásico

El estímulo incondicionado desencadena una respuesta sin aprendizaje previo. La respuesta incondicionada es esa reacción no aprendida. El estímulo condicionado adquiere su efecto mediante la asociación; la respuesta condicionada es la respuesta aprendida.
No confundas estímulo, que se presenta, con respuesta, que hace el organismo. Una reacción anticipatoria aprendida no demuestra por sí sola una nueva lesión.

### Refuerzo y castigo

Refuerzo significa que aumenta la probabilidad de una conducta. Castigo significa que disminuye. Positivo indica que se añade un estímulo; negativo, que se retira. Estas palabras no equivalen a bueno y malo.
Refuerzo positivo: se añade una consecuencia y la conducta aumenta. Refuerzo negativo: se retira una consecuencia aversiva y la conducta aumenta. Castigo negativo: se retira una consecuencia agradable y la conducta disminuye. Por tanto, refuerzo negativo y castigo no son sinónimos.

### Moldeamiento

Consiste en reforzar aproximaciones sucesivas a la conducta objetivo. En lugar de exigir desde el principio una ejecución completa, se reconocen pasos cada vez más cercanos al objetivo. Es un concepto de aprendizaje, no una prescripción automática de ejercicio para cualquier paciente.

### Relación terapéutica

El programa incluye comunicación, obstáculos comunicativos y adherencia. Comprender el comportamiento ayuda a formular preguntas sobre dificultades reales y adaptar la explicación. Se mantiene el respeto por la persona y sus decisiones; conocer un mecanismo de aprendizaje no autoriza a manipularla.

### Aplicación

Si un reconocimiento verbal tras una práctica se acompaña de un aumento de esa conducta, encaja con refuerzo positivo. Para clasificar el mecanismo hay que comprobar qué se añade o retira y cómo cambia la conducta; la intención del profesional no basta.

### Autoevaluación

Construye una tabla de dos criterios: añadir o retirar, aumentar o disminuir. Explica por qué retirar un estímulo no significa siempre castigar.

Material de entrenamiento original, no examen oficial.') THEN RAISE EXCEPTION 'Formatting conflict'; END IF; END $test$;
DO $test$ BEGIN IF NOT EXISTS(SELECT 1 FROM public.curriculum_lessons WHERE id='b7301030-2026-4000-8002-000000000002' AND content='### Objetivos de repaso

Reconocer determinantes sociales de la salud, analizar barreras de acceso y comprender la diversidad sin convertirla en estereotipos. Este bloque desarrolla contenidos de desigualdad y comunicación intercultural.

### Salud y condiciones de vida

Los determinantes sociales son las condiciones en que las personas nacen, crecen, viven, trabajan y envejecen, junto con las fuerzas sociales, políticas y económicas que las configuran. Incluyen vivienda, educación, alimentación, trabajo y protección social. La atención sanitaria importa, pero no agota las causas de la salud.

### Gradiente social

Las diferencias de salud no se limitan a una separación entre pobreza extrema y el resto de la población. El gradiente social describe una relación progresiva entre desventaja social y peores resultados de salud. Es una relación poblacional; no permite predecir con certeza la salud de cada individuo.

### Desigualdad y equidad

Describir una diferencia es un primer paso. Analizar la equidad exige preguntarse por la distribución de recursos, oportunidades y barreras. Ofrecer exactamente el mismo recurso puede dejar sin acceso a quienes encuentran obstáculos distintos. Mejorar el acceso puede requerir respuestas adaptadas al contexto.

### Diversidad y comunicación

La antropología de la salud estudia las creencias y prácticas relacionadas con salud, enfermedad y cuidados dentro de su contexto. Una nacionalidad no determina por sí sola lo que cree una persona. Conviene explorar cómo entiende su problema, qué espera de la atención y qué dificultades comunicativas existen, con respeto y sin suposiciones.

### Género, estigma y discriminación

El programa incluye estas dimensiones porque pueden influir en experiencias y oportunidades. Un análisis respetuoso evita culpar a un colectivo y examina barreras y relaciones sociales. La participación de la persona en la atención ayuda a comprender su situación concreta.

### Aplicación en fisioterapia

Una persona no acude porque sus turnos laborales y el transporte dificultan la asistencia. Antes de atribuirlo a falta de interés, se exploran esas barreras y las opciones de coordinación. Una vivienda inadecuada o la dificultad para costear desplazamientos también pueden condicionar el seguimiento.

### Autoevaluación

Separa en un caso lo observado de lo supuesto. Identifica una barrera social, una pregunta para comprenderla y una posible adaptación que deba discutirse con la persona y el equipo.

Material original de entrenamiento basado en UVic y OMS; no es un examen oficial.') THEN RAISE EXCEPTION 'Formatting conflict'; END IF; END $test$;
DO $test$ BEGIN IF NOT EXISTS(SELECT 1 FROM public.curriculum_quiz_questions WHERE id='9ddd8f72-fdde-46bb-930f-2f1498e8f956' AND question_text='Caso profesional — Una situación supera claramente el ámbito de actuación del estudiante. ¿Qué conducta es la más segura?' AND options='[{"text":"Reconocer el límite y pedir supervisión","correct":true},{"text":"Improvisar una intervención no dominada","correct":false},{"text":"Ocultar la dificultad al supervisor","correct":false},{"text":"Actuar sin informar al paciente","correct":false}]'::jsonb) THEN RAISE EXCEPTION 'Question revision conflict'; END IF; END $test$;
DO $test$ BEGIN IF NOT EXISTS(SELECT 1 FROM public.curriculum_quiz_questions WHERE id='e4b0d8b5-cfa9-4d2a-99ca-0619e8f520c5' AND question_text='¿Qué combinación describe mejor una práctica profesional respetuosa?' AND options='[{"text":"Información comprensible + consentimiento + respeto de la autonomía","correct":true},{"text":"Técnica impuesta sin explicación","correct":false},{"text":"Decisión sin participación del paciente","correct":false},{"text":"Intervención fuera de las propias competencias","correct":false}]'::jsonb) THEN RAISE EXCEPTION 'Question revision conflict'; END IF; END $test$;
COMMIT;
