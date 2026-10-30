BEGIN;
UPDATE public.curriculum_quiz_questions SET is_published=false,updated_at=now() WHERE metadata->>'content_batch'='es-s1-suite-20261030';
UPDATE public.curriculum_lessons SET is_published=false,updated_at=now() WHERE id IN ('c7301030-2026-4000-8002-000000000001','c7301030-2026-4000-8002-000000000002','c7301030-2026-4000-8002-000000000003','c7301030-2026-4000-8002-000000000004','c7301030-2026-4000-8002-000000000005','c7301030-2026-4000-8002-000000000006','c7301030-2026-4000-8002-000000000007');
UPDATE public.curriculum_topics SET is_active=false,updated_at=now() WHERE id IN ('c7301030-2026-4000-8001-000000000001','c7301030-2026-4000-8001-000000000002','c7301030-2026-4000-8001-000000000003','c7301030-2026-4000-8001-000000000004','c7301030-2026-4000-8001-000000000005','c7301030-2026-4000-8001-000000000006');
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

Material de entrenamiento original basado en fuentes; no es un examen oficial.',updated_at=now() WHERE id='21afcaf4-82c8-4ea6-8778-dd0ee108ec6b' AND content='### Objetivos de repaso

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
UPDATE public.curriculum_lessons SET content='Fisiología II introduce conceptos de neurociencia relevantes para comprender el movimiento y la función. La neuroplasticidad describe la capacidad del sistema nervioso para modificar su organización y funcionamiento en respuesta a la experiencia y al aprendizaje.\n\nEl sistema somatosensorial aporta información sobre el cuerpo, mientras que los sistemas visual y vestibular también participan en la orientación y el control postural. El control motor integra información sensorial y órdenes motoras para producir movimientos adaptados.\n\nEl aprendizaje motor, la atención y la memoria influyen en la adquisición y repetición de habilidades. Estos conceptos ayudan a comprender por qué la práctica, la retroalimentación y el contexto son importantes durante la rehabilitación.

En rehabilitación, la práctica repetida cobra sentido cuando el paciente recibe información útil sobre el resultado y la ejecución. El feedback permite ajustar el movimiento, mientras que la repetición en contextos variados favorece el aprendizaje y la transferencia a tareas funcionales. La dificultad debe progresar sin perder seguridad ni calidad de movimiento.',updated_at=now() WHERE id='3bd5d230-90e8-4e09-9487-b7a75accb5a2' AND content='Fisiología II introduce conceptos de neurociencia relevantes para comprender el movimiento y la función. La neuroplasticidad describe la capacidad del sistema nervioso para modificar su organización y funcionamiento en respuesta a la experiencia y al aprendizaje.

El sistema somatosensorial aporta información sobre el cuerpo, mientras que los sistemas visual y vestibular también participan en la orientación y el control postural. El control motor integra información sensorial y órdenes motoras para producir movimientos adaptados.

El aprendizaje motor, la atención y la memoria influyen en la adquisición y repetición de habilidades. Estos conceptos ayudan a comprender por qué la práctica, la retroalimentación y el contexto son importantes durante la rehabilitación.

En rehabilitación, la práctica repetida cobra sentido cuando el paciente recibe información útil sobre el resultado y la ejecución. El feedback permite ajustar el movimiento, mientras que la repetición en contextos variados favorece el aprendizaje y la transferencia a tareas funcionales. La dificultad debe progresar sin perder seguridad ni calidad de movimiento.';
UPDATE public.curriculum_lessons SET content='La historia clínica organiza la información relevante de la persona: motivo de consulta, antecedentes, síntomas, evolución y repercusión funcional. La entrevista clínica permite completar esta información mediante preguntas claras y dirigidas.\n\nLa semiología ayuda a describir signos y síntomas de forma ordenada. En fisioterapia, esta información se relaciona con la valoración de las capacidades funcionales y con el análisis del movimiento y de la actividad.\n\nEl diagnóstico funcional de fisioterapia sintetiza los hallazgos relevantes para orientar los objetivos de intervención. No consiste únicamente en nombrar una patología, sino en comprender cómo la situación afecta a la función.

### Approfondissement
Una buena historia clínica no es una lista de datos aislados. Debe organizar la información relevante, relacionar síntomas y evolución con el impacto funcional y orientar la exploración. El diagnóstico funcional sintetiza lo que la persona puede o no puede hacer, qué factores lo limitan y qué objetivos de fisioterapia son prioritarios.',updated_at=now() WHERE id='7e9e37d5-20fa-49fc-bbbf-aee1bc790db5' AND content='La historia clínica organiza la información relevante de la persona: motivo de consulta, antecedentes, síntomas, evolución y repercusión funcional. La entrevista clínica permite completar esta información mediante preguntas claras y dirigidas.

La semiología ayuda a describir signos y síntomas de forma ordenada. En fisioterapia, esta información se relaciona con la valoración de las capacidades funcionales y con el análisis del movimiento y de la actividad.

El diagnóstico funcional de fisioterapia sintetiza los hallazgos relevantes para orientar los objetivos de intervención. No consiste únicamente en nombrar una patología, sino en comprender cómo la situación afecta a la función.

### Approfondissement

Una buena historia clínica no es una lista de datos aislados. Debe organizar la información relevante, relacionar síntomas y evolución con el impacto funcional y orientar la exploración. El diagnóstico funcional sintetiza lo que la persona puede o no puede hacer, qué factores lo limitan y qué objetivos de fisioterapia son prioritarios.';
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

Ejercicios originales de entrenamiento; no son preguntas de examen autenticadas.',updated_at=now() WHERE id='ab7d1b48-00b2-45f3-97ae-c055c7a6a0e0' AND content='### Objetivos de repaso

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
UPDATE public.curriculum_lessons SET content='El ejercicio terapéutico utiliza movimientos y actividades planificadas con un objetivo funcional. No se trata simplemente de hacer ejercicio: en fisioterapia, cada propuesta debe relacionarse con una capacidad que se quiere mantener, recuperar o mejorar.\n\nLa planificación tiene en cuenta las capacidades físicas básicas y la respuesta de la persona al esfuerzo. La progresión debe ser gradual y coherente con el nivel funcional observado.\n\nLa prescripción forma parte de la intervención fisioterapéutica. El estudiante debe aprender a relacionar el ejercicio elegido con un objetivo concreto, observar la tolerancia y adaptar la dificultad cuando sea necesario.

### Approfondissement
Un ejercicio terapéutico debe tener un objetivo observable. Por ejemplo, mejorar la capacidad de levantarse de una silla no exige el mismo trabajo que mejorar el equilibrio o la movilidad de hombro. La progresión puede modificarse aumentando repeticiones, resistencia, amplitud o complejidad, siempre observando la tolerancia. La respuesta del paciente sirve para decidir si mantener, facilitar o aumentar la dificultad.',updated_at=now() WHERE id='3d6bb405-866f-4daf-acb9-618bd8cc2100' AND content='El ejercicio terapéutico utiliza movimientos y actividades planificadas con un objetivo funcional. No se trata simplemente de hacer ejercicio: en fisioterapia, cada propuesta debe relacionarse con una capacidad que se quiere mantener, recuperar o mejorar.

La planificación tiene en cuenta las capacidades físicas básicas y la respuesta de la persona al esfuerzo. La progresión debe ser gradual y coherente con el nivel funcional observado.

La prescripción forma parte de la intervención fisioterapéutica. El estudiante debe aprender a relacionar el ejercicio elegido con un objetivo concreto, observar la tolerancia y adaptar la dificultad cuando sea necesario.

### Approfondissement

Un ejercicio terapéutico debe tener un objetivo observable. Por ejemplo, mejorar la capacidad de levantarse de una silla no exige el mismo trabajo que mejorar el equilibrio o la movilidad de hombro. La progresión puede modificarse aumentando repeticiones, resistencia, amplitud o complejidad, siempre observando la tolerancia. La respuesta del paciente sirve para decidir si mantener, facilitar o aumentar la dificultad.';
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

Material de repaso original basado en las fuentes enlazadas; no es una reproducción del curso ni un examen oficial.',updated_at=now() WHERE id='502486f5-ff65-4a23-82fe-40d4408de8d1' AND content='### Objetivos de repaso

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
UPDATE public.curriculum_lessons SET content='Comprender al paciente exige identificar el vocabulario de dolor y función sin interpretar automáticamente un diagnóstico. Frases como «Me duele la cadera cuando camino» o «No puedo apoyar bien la pierna» describen una molestia y una limitation funcional concreta.\n\nTambién son frecuentes expresiones como «Tengo rigidez por la mañana» o «El dolor mejora cuando descanso». El estudiante debe repérer douleur, appui, raideur, marche et repos dans leur contexte clinique.\n\nL’objectif est de comprendre ce que le patient exprime, puis de savoir reformuler l’information avant toute interprétation clinique.

### Cómo analizar el mensaje
Primero se identifica el síntoma expresado por el paciente, después la actividad afectada y por último el factor que modifica la molestia. “Me duele la cadera cuando camino” contiene dolor + localización + actividad; “no puedo apoyar bien la pierna” señala una limitación funcional. Esta lectura por bloques ayuda a reformular con precisión sin transformar automáticamente la plainte en diagnostic.',updated_at=now() WHERE id='865fe31e-5a66-4b18-a370-9273f660c296' AND content='Comprender al paciente exige identificar el vocabulario de dolor y función sin interpretar automáticamente un diagnóstico. Frases como «Me duele la cadera cuando camino» o «No puedo apoyar bien la pierna» describen una molestia y una limitation funcional concreta.

También son frecuentes expresiones como «Tengo rigidez por la mañana» o «El dolor mejora cuando descanso». El estudiante debe repérer douleur, appui, raideur, marche et repos dans leur contexte clinique.

L’objectif est de comprendre ce que le patient exprime, puis de savoir reformuler l’information avant toute interprétation clinique.

### Cómo analizar el mensaje

Primero se identifica el síntoma expresado por el paciente, después la actividad afectada y por último el factor que modifica la molestia. “Me duele la cadera cuando camino” contiene dolor + localización + actividad; “no puedo apoyar bien la pierna” señala una limitación funcional. Esta lectura por bloques ayuda a reformular con precisión sin transformar automáticamente la plainte en diagnostic.';
UPDATE public.curriculum_lessons SET content='El rango de movimiento del hombro describe cuánto puede desplazarse la articulación en diferentes direcciones. En la valoración se observa la movilidad y se buscan limitaciones, rigidez o debilidad que puedan interferir con la función.\n\nLos ejercicios pueden dirigirse a estirar y fortalecer los músculos que rodean el hombro y la escápula. El objetivo no es solamente aumentar fuerza, sino favorecer un movimiento más eficaz y funcional.\n\nDurante la práctica, el estudiante debe relacionar movilidad, fuerza y síntomas con actividades concretas del miembro superior, evitando interpretar un dato aislado fuera del conjunto de la valoración.

### Raisonnement simple
Une épaule peut présenter une limitation de mouvement, une faiblesse, une raideur ou une combinaison de ces éléments. L’exercice choisi doit donc être relié à ce qui est observé : étirer lorsqu’un travail de mobilité est recherché, renforcer lorsqu’un déficit de force est identifié, et toujours vérifier le retentissement fonctionnel. Le suivi s’appuie sur l’évolution des symptômes et de la capacité à réaliser les activités du membre supérieur.',updated_at=now() WHERE id='ca4270be-ba6e-4442-b152-33c8472f679c' AND content='El rango de movimiento del hombro describe cuánto puede desplazarse la articulación en diferentes direcciones. En la valoración se observa la movilidad y se buscan limitaciones, rigidez o debilidad que puedan interferir con la función.

Los ejercicios pueden dirigirse a estirar y fortalecer los músculos que rodean el hombro y la escápula. El objetivo no es solamente aumentar fuerza, sino favorecer un movimiento más eficaz y funcional.

Durante la práctica, el estudiante debe relacionar movilidad, fuerza y síntomas con actividades concretas del miembro superior, evitando interpretar un dato aislado fuera del conjunto de la valoración.

### Raisonnement simple

Une épaule peut présenter une limitation de mouvement, une faiblesse, une raideur ou une combinaison de ces éléments. L’exercice choisi doit donc être relié à ce qui est observé : étirer lorsqu’un travail de mobilité est recherché, renforcer lorsqu’un déficit de force est identifié, et toujours vérifier le retentissement fonctionnel. Le suivi s’appuie sur l’évolution des symptômes et de la capacité à réaliser les activités du membre supérieur.';
UPDATE public.curriculum_lessons SET content='En la exploración cardio-respiratoria se utilizan varios signos y términos básicos. El pulso permite estimar la frecuencia cardíaca; la frecuencia respiratoria describe el número de respiraciones por minuto; la presión arterial es otro signo vital importante.\n\nDurante el ejercicio o una prueba de esfuerzo también pueden aparecer síntomas relevantes como falta de aire, palpitaciones, mareo o dolor torácico. Reconocer este vocabulario ayuda a comprender las indicaciones y a comunicar síntomas con precisión.\n\nEquivalencias útiles: pulso = pouls, frecuencia cardíaca = fréquence cardiaque, presión arterial = pression artérielle, falta de aire = essoufflement.

### Approfondissement
Para interpretar correctamente una situación cardio-respiratoria, conviene relacionar cada término con una medida o un síntoma concreto. “Pulso” y “frecuencia cardíaca” se refieren al ritmo del corazón; “frecuencia respiratoria” al número de respiraciones por minuto; “presión arterial” a la tensión ejercida por la sangre en las arterias. Durante el esfuerzo, síntomas como falta de aire, palpitaciones, mareo o dolor torácico deben describirse con precisión, indicando cuándo aparecen y si obligan a detener la actividad.',updated_at=now() WHERE id='58a2ea17-3a47-4551-95eb-8be4924678bc' AND content='En la exploración cardio-respiratoria se utilizan varios signos y términos básicos. El pulso permite estimar la frecuencia cardíaca; la frecuencia respiratoria describe el número de respiraciones por minuto; la presión arterial es otro signo vital importante.

Durante el ejercicio o una prueba de esfuerzo también pueden aparecer síntomas relevantes como falta de aire, palpitaciones, mareo o dolor torácico. Reconocer este vocabulario ayuda a comprender las indicaciones y a comunicar síntomas con precisión.

Equivalencias útiles: pulso = pouls, frecuencia cardíaca = fréquence cardiaque, presión arterial = pression artérielle, falta de aire = essoufflement.

### Approfondissement

Para interpretar correctamente una situación cardio-respiratoria, conviene relacionar cada término con una medida o un síntoma concreto. “Pulso” y “frecuencia cardíaca” se refieren al ritmo del corazón; “frecuencia respiratoria” al número de respiraciones por minuto; “presión arterial” a la tensión ejercida por la sangre en las arterias. Durante el esfuerzo, síntomas como falta de aire, palpitaciones, mareo o dolor torácico deben describirse con precisión, indicando cuándo aparecen y si obligan a detener la actividad.';
UPDATE public.curriculum_lessons SET content='El vocabulario neuromotor aparece constantemente en la valoración funcional. Equilibrio describe la capacidad de mantener o recuperar una posición estable; coordinación se refiere a la organización adecuada de los movimientos; sensibilidad permite percibir estímulos procedentes del cuerpo y del entorno.\n\nMarcha significa caminar. Una caída puede relacionarse con problemas de equilibrio, debilidad o alteraciones de la marcha, aunque estos términos por sí solos no establecen un diagnóstico.\n\nEn contexto clínico conviene reconocer también nervio, control motor y estabilidad. Dominar estas palabras permite comprender mejor las consignas, la entrevista y las situaciones funcionales descritas por el paciente.

### Aplicación clínica

Ante una queja de inestabilidad, separa equilibrio, coordinación, sensibilidad, fuerza y marcha. Preguntas simples permiten saber si el problema aparece de pie, al caminar, al girar o dans l’obscurité. El objetivo inicial es describir el déficit funcional antes de buscar una explicación causal.',updated_at=now() WHERE id='77ed1803-59cd-44c7-8d0a-67db4e96d2a7' AND content='El vocabulario neuromotor aparece constantemente en la valoración funcional. Equilibrio describe la capacidad de mantener o recuperar una posición estable; coordinación se refiere a la organización adecuada de los movimientos; sensibilidad permite percibir estímulos procedentes del cuerpo y del entorno.

Marcha significa caminar. Una caída puede relacionarse con problemas de equilibrio, debilidad o alteraciones de la marcha, aunque estos términos por sí solos no establecen un diagnóstico.

En contexto clínico conviene reconocer también nervio, control motor y estabilidad. Dominar estas palabras permite comprender mejor las consignas, la entrevista y las situaciones funcionales descritas por el paciente.

### Aplicación clínica

Ante una queja de inestabilidad, separa equilibrio, coordinación, sensibilidad, fuerza y marcha. Preguntas simples permiten saber si el problema aparece de pie, al caminar, al girar o dans l’obscurité. El objetivo inicial es describir el déficit funcional antes de buscar una explicación causal.';
UPDATE public.curriculum_lessons SET content='La muñeca conecta el antebrazo con la mano y permite orientar la mano para las actividades de prensión, apoyo y manipulación. En esta región pasan tendones que movilizan los dedos y también estructuras nerviosas importantes.\n\nEl nervio mediano atraviesa el túnel carpiano. Una alteración en esta zona puede modificar la sensibilidad y la función de la mano. Por eso, en fisioterapia es útil relacionar movilidad de muñeca, deslizamiento tendinoso, sensibilidad y capacidad funcional.\n\nVocabulario útil: muñeca = poignet, mano = main, nervio mediano = nerf médian, tendón = tendon, sensibilidad = sensibilité.

### Relación estructura-función
La muñeca no se estudia de forma aislada de la mano. Una limitación de movilidad puede modificar la orientación de la mano durante la prensión o el apoyo. Del mismo modo, sensibilidad y función deben relacionarse con el trayecto nervioso y con las tareas que la persona tiene dificultad para realizar. En una exploración básica, el estudiante distingue por tanto movilidad, sensibilidad y capacidad funcional antes de sacar conclusiones.',updated_at=now() WHERE id='599a84b0-9acf-45a1-9cf9-101fa2b2e192' AND content='La muñeca conecta el antebrazo con la mano y permite orientar la mano para las actividades de prensión, apoyo y manipulación. En esta región pasan tendones que movilizan los dedos y también estructuras nerviosas importantes.

El nervio mediano atraviesa el túnel carpiano. Una alteración en esta zona puede modificar la sensibilidad y la función de la mano. Por eso, en fisioterapia es útil relacionar movilidad de muñeca, deslizamiento tendinoso, sensibilidad y capacidad funcional.

Vocabulario útil: muñeca = poignet, mano = main, nervio mediano = nerf médian, tendón = tendon, sensibilidad = sensibilité.

### Relación estructura-función

La muñeca no se estudia de forma aislada de la mano. Una limitación de movilidad puede modificar la orientación de la mano durante la prensión o el apoyo. Del mismo modo, sensibilidad y función deben relacionarse con el trayecto nervioso y con las tareas que la persona tiene dificultad para realizar. En una exploración básica, el estudiante distingue por tanto movilidad, sensibilidad y capacidad funcional antes de sacar conclusiones.';
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

Material de entrenamiento original, no examen oficial.',updated_at=now() WHERE id='b7301030-2026-4000-8002-000000000001' AND content='### Objetivos de repaso

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

Material de entrenamiento original, no examen oficial.';
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

Material original de entrenamiento basado en UVic y OMS; no es un examen oficial.',updated_at=now() WHERE id='b7301030-2026-4000-8002-000000000002' AND content='### Objetivos de repaso

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

Material original de entrenamiento basado en UVic y OMS; no es un examen oficial.';
UPDATE public.curriculum_quiz_questions SET question_text='Caso profesional — Una situación dépasse clairement le ámbito de actuación del estudiante. ¿Qué conducta es la más segura?',explanation='Reconocer los límites de actuación y solicitar ayuda forma parte de una práctica segura.',options='[{"text":"Reconocer el límite y pedir supervisión","correct":true},{"text":"Improvisar una intervención no dominada","correct":false},{"text":"Ocultar la dificultad al supervisor","correct":false},{"text":"Actuar sin informar al paciente","correct":false}]'::jsonb,source_label='UVic-UCC — Fonaments de la Fisioteràpia 2026-2027',metadata='{"batch":"10","difficulty_scale_version":"2026-10-v1"}'::jsonb,updated_at=now() WHERE id='9ddd8f72-fdde-46bb-930f-2f1498e8f956' AND question_text='Caso profesional — Una situación supera claramente el ámbito de actuación del estudiante. ¿Qué conducta es la más segura?';
UPDATE public.curriculum_quiz_questions SET question_text='¿Qué combinaison décrit le mieux une pratique professionnelle respectueuse?',explanation='La pratique associe compétence, information compréhensible, consentement et respect de l’autonomie.',options='[{"text":"Información comprensible + consentimiento + respeto de la autonomía","correct":true},{"text":"Technique imposée sans explication","correct":false},{"text":"Décision sans participation du patient","correct":false},{"text":"Intervention hors compétences","correct":false}]'::jsonb,source_label='UVic-UCC — Fonaments de la Fisioteràpia 2026-2027',metadata='{"batch":"10","difficulty_scale_version":"2026-10-v1"}'::jsonb,updated_at=now() WHERE id='e4b0d8b5-cfa9-4d2a-99ca-0619e8f520c5' AND question_text='¿Qué combinación describe mejor una práctica profesional respetuosa?';
COMMIT;
