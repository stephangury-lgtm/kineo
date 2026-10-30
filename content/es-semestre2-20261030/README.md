# Espagne — Semestre 2

Publié le 30 octobre 2026 dans le catalogue `kineo-es`, première année ES1, version `default`. ES2 désigne la deuxième année et n'a pas été modifiée.

## Périmètre

5 unités explicites, 20 chapitres avec une fiche et 10 questions chacun :

| Unité | Chapitres | Questions |
|---|---:|---:|
| Anatomía II | 5 | 50 |
| Fisiología II | 4 | 40 |
| Biofísica y Biomecánica | 5 | 50 |
| Bases de la Práctica en Fisioterapia | 3 | 30 |
| Inglés para las Ciencias de la Salud | 3 | 30 |

200 questions originales : 166 QCM et 34 situations ou applications. Espagnol pour les cours scientifiques ; exercices en anglais et accompagnement en espagnol pour l'anglais. Les unités S1 et leurs 280 questions sont inchangées.

64 anciens exercices harmonisés sans changer leurs identifiants, types ou réponses libres acceptées : 35 prompts/options/corrections en espagnol ; 29 exercices de traduction explicitement marqués « Vocabulario FR/ES » conservent leurs réponses françaises. Révision éditoriale, sans nouvelle validation médicale de ces anciens exercices. Aucun transfert ni suppression d'historique étudiant.

## Sources et limites

Alignement thématique sur les plans UVic consultés : Anatomía II (4403), Biofísica y Biomecánica (4404), Fisiología II (4406), Bases de la Práctica (7481), Inglés para las Ciencias de la Salud (4431). Sources de chaque fiche/question dans le bundle : OpenStax A&P, Physics, Psychology, British Council, NHS, CDC, NIH/NINDS, MedlinePlus, OMS et page officielle ACSM pour le vocabulaire FITT. Sources consultées le 30 octobre 2026 ; aucun manuel ACSM intégral prétendument lu.

Socle complémentaire de révision, pas couverture certifiée des 30 ECTS, ni annales officielles, ni validation d'un niveau B2. Relecture par un enseignant en attente. Les pratiques supervisées et les supports du centre restent nécessaires. Pas de mise à jour des PDF ni de test visuel navigateur dans ce lot.

## Vérifications

- Structure : 20 fiches, 200 questions, quatre options distinctes et une seule correcte pour chaque nouvelle question ; pas de doublon exact de prompt dans le lot ou avec le catalogue précédent.
- Application de la publication puis retour arrière en transaction : succès.
- Rôle étudiant existant : cinq unités, vingt fiches et 200 questions accessibles ; aucune réponse correcte ou explication divulguée par le RPC initial.
- 46 soumissions via le RPC utilisé par l'application : réponse correcte et incorrecte pour 23 questions, dont trois situations et les trois chapitres d'anglais. Corrigés retournés après soumission. Toutes les écritures de test annulées par SAVEPOINT.
- Comparaison complète des 280 lignes de questions S1 : inchangées.
- Publication effective et contrôle des volumes par unité.

## Fichiers

- `bundle.json` : nouvelles lignes et sauvegarde des 64 questions avant révision.
- `publish.sql` : DML transactionnel exécuté une seule fois ; les identifiants déterministes rendent une deuxième exécution bloquante.
- `acceptance.sql` : à exécuter seulement avant publication, sur une copie de l'état initial ; inclut publication, tests étudiant, vérification du retour arrière et ROLLBACK final.
- `rollback.sql` : désactive les nouvelles unités et leur contenu sans supprimer les tentatives ; restaure les 64 exercices seulement si leur prompt/options/étiquette de révision correspondent encore au lot. Vérifier les modifications ultérieures avant de l'utiliser. Le retour arrière ne remet pas les horodatages historiques.

Les contenus étant chargés dynamiquement, aucune modification du frontend ni de schéma, d'authentification ou de RLS n'a été nécessaire.
