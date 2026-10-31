# Première année Espagne — ateliers de consolidation — 31 octobre 2026

Publié dans le catalogue `kineo-es`, année ES1, version `default`.

## Résultat

- 10 ateliers, un dans chacune des dix matières S1–S2.
- 10 fiches d'application avec exemples résolus, calculs ou raisonnement explicite et méthode d'analyse des erreurs.
- 120 exercices : 40 QCM, 40 mises en situation, 20 textes à compléter et 20 associations.
- 2 fiches existantes d'anatomie (main et pied) : tableaux Markdown remplacés par listes lisibles dans le lecteur actuel, sans changer les faits.
- Parcours structuré après publication : **90 chapitres, 91 fiches dont un guide et 920 questions corrigées**.

Les ateliers sont ajoutés comme nouveaux chapitres de fin de matière. Cela conserve les identifiants, tentatives et validations des chapitres déjà étudiés.

| Matière | Atelier |
|---|---|
| Anatomía I | Du tissu à l'organe ; trajets digestif et urinaire |
| Fisiología I | Cycle cardiaque, gradients et ventilation |
| Fundamentos | Entretien, données, hypothèses et problème fonctionnel |
| Psicología | Apprentissage, adhérence et communication |
| Cultura, Sociedad y Salud | Équité, accès et barrières |
| Anatomía II | Orientation osseuse, coude, cheville et doigts |
| Fisiología II | Entrée sensorielle, intégration et réponse motrice |
| Biofísica y Biomecánica | Moments, équilibre, efforts et déformation relative |
| Bases de la Práctica | FITT, effort relatif, progression et sécurité |
| Inglés | Questions, lecture et clarification d'une note originale |

## Choix pédagogiques

Chaque atelier comprend quatre QCM de compréhension, quatre situations d'application, deux réponses courtes et deux associations de trois éléments. La difficulté 2/3 est une appréciation éditoriale ; aucune calibration psychométrique ou équivalence avec les examens UVic n'est revendiquée.

Les choix incorrects visent des confusions identifiées : grandeur/unité, trajet/production, observation/hypothèse, données manquantes/diagnostic, fréquence/durée, etc. Les corrections des questions à choix expliquent la bonne réponse et les erreurs des alternatives. Les réponses numériques précisent unité attendue et consigne sur nombre seul. Les réponses courtes acceptent des variantes explicites pertinentes. Les associations utilisent des éléments distincts.

Les valeurs et situations sont originales et identifiées comme pédagogiques ; elles ne proviennent pas de patients ni d'études réelles. Les calculs ne donnent pas de doses ou seuils individuels de traitement.

Le lecteur ReadableCourseContent ne transforme pas les tables Markdown en tables HTML. Deux fiches anatomiques qui contenaient des tables brutes ont donc été reformulées en listes prises en charge, avec sauvegarde avant/après. Le contenu du frontend n'a pas changé.

Les références des nouveaux ateliers ont un titre affichable dans CompactReferences, avec lien et date de consultation.

## Sources

Sources par fiche et exercice dans bundle.json, liste dans sources.json : OpenStax A&P et University Physics pour les mécanismes et modèles ; OMS pour CIF et déterminants ; NICE NG197 pour décision partagée ; British Council pour grammaire ; CDC pour intensité ; MedlinePlus pour sécurité ; page officielle ACSM pour définition FITT uniquement. Aucun livre payant ACSM n'est présenté comme intégralement consulté.

Questions d'entraînement originales, pas annales authentifiées. L'alignement de ces ateliers utilise les dix matières UVic déjà vérifiées lors du bilan précédent. Relecture indépendante enseignante toujours en attente.

Ces ajouts renforcent compréhension et application ; ils ne certifient pas la couverture exhaustive des 60 ECTS, la pratique clinique ou l'anglais oral. Pas de nouveaux visuels anatomiques, pas de modification de PDF, pas de test visuel navigateur dans ce lot.

## Vérification

- Intégration frontend existante inspectée : CurriculumTopicPage prend en charge les quatre formats via les métadonnées sûres du RPC, et CompactReferences affiche les sources.
- Aucun doublon de libellé normalisé entre les 120 exercices et les 1499 questions de première année existantes.
- Publication et retour arrière testés en transaction.
- Accès sous droits d'un étudiant ES1 existant : dix fiches et 120 questions lisibles.
- Avant réponse : explications masquées, aucun drapeau correct, aucune réponse libre ni paire correcte exposée ; les associations fournissent les deux listes sans correspondance.
- **272 soumissions de contrôle annulées** : réponse juste et fausse pour chacun des 120 exercices, plus 32 variantes de réponses courtes. Associations correctes soumises dans l'ordre inversé ; association incorrecte avec doublon rejetée. Corrections retournées après réponse.
- Six cohortes avec SAVEPOINT évitent de conserver tentatives, XP ou notifications de test.
- Après publication : 90 chapitres, 91 fiches, 920 questions ; douze exercices jouables dans chacun des dix ateliers ; zéro tentative de test persistée.
- Empreintes de toutes les questions préexistantes, unités et chapitres inchangées ; fiches inchangées sauf les deux mises en forme documentées.
- Authentification, schéma et politiques RLS inchangés.

## Fichiers et retour arrière

- bundle.json : nouvelles lignes et sauvegarde complète des deux fiches modifiées.
- publish.sql : DML exécuté une fois, protégé par empreintes et contrôle du contenu attendu pour les deux mises en forme.
- acceptance.sql : à exécuter sur état prépublication ou copie correspondante ; termine par ROLLBACK.
- rollback.sql : désactive les nouveaux contenus et restaure les deux textes si leur contenu correspond encore à ce lot. Les tentatives ultérieures sont conservées. Vérifier les changements postérieurs avant de l'appliquer ; les horodatages historiques ne sont pas restaurés.

La publication Supabase est effective. La PR en brouillon conserve les données, scripts et justificatifs de revue ; aucune fusion ou publication du frontend n'est annoncée.
