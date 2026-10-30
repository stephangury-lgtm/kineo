# Espagne · S1 · socle de révision opérationnel · 2026-10-30

## Résultat publié
Cinq matières séparées des compléments de première année :
| Matière | Chapitres | Fiches | Questions |
|---|---:|---:|---:|
| Anatomía I | 6 | 6 | 60 |
| Fisiología I | 11 | 11 | 110 |
| Fundamentos de la Fisioterapia | 3 | 3 | 30 |
| Psicología | 5 | 6 | 50 |
| Cultura, Sociedad y Salud | 3 | 3 | 30 |
| Total | 28 | 29 | 280 |

Dix questions par chapitre, quatre options et une bonne réponse. La fiche supplémentaire est le guide d'étude. Les 170 nouvelles questions complètent les 110 des deux lots précédents. Les huit anciens ensembles annuels sont renommés comme appui ou compléments ; deux devenus vides sont masqués. Les sujets de S1 sont placés dans cinq rubriques en tête de catalogue.

## Sources et couverture
Les plans publics UVic sont vérifiés pour les cinq matières. Les contenus détaillés reposent sur OpenStax, OMS, World Physiotherapy et NICE selon les fiches.
Les grands blocs présents sont : cellule et division, tissus, embryologie, cœur, respiration, lymphe, membrane, génétique, homeostasis, sang, immunité, fonctions cardiaque/digestive/rénale/endocrine/reproductive, CIF, exercice et familles de procédures, modèles psychologiques, développement, stress/duel, communication, déterminants, culture et genre.
Les appareils digestif, urinaire et reproducteur associent anatomie et fonction dans les chapitres correspondants.

Il s'agit d'un socle complémentaire de révision, pas de l'intégralité des 30 ECTS ni d'une garantie de réussite à un examen. La revue pédagogique par enseignant reste à faire. Des détails de l'histoire antique/espagnole/catalane, des mécanismes avancés et des attentes exactes d'examen doivent être approfondis avec la bibliographie et les cours du professeur. La fiche professionnelle l'indique explicitement et propose une source institutionnelle pour l'histoire catalane. Le livre complet catalan n'a pas pu être extrait : aucune affirmation interne n'est déduite de ce contenu non lu.
Les PDF anciens ne sont pas présentés comme les supports actualisés : les fiches de ce parcours sont numériques et sourcées. Aucun nouveau PDF n'est hébergé par ce lot.

## Parcours et protection de l'historique
Trente questions sans tentative au moment du contrôle sont rattachées à trois nouveaux chapitres propres au S1. Leurs IDs restent identiques. Une garde transactionnelle bloque l'opération si une tentative apparaît avant application. Les trois fiches générales sont copiées ; les originaux et leurs IDs restent disponibles dans les compléments.
Les huit autres chapitres déjà créés changent de rubrique sans changement d'ID. Aucun compte, droit ou enregistrement de progression n'est modifié par la publication.

## Validation
- Import complet testé avec ROLLBACK.
- Lecture sous rôle authenticated avec affectation Espagne : cinq rubriques, 28 chapitres et 280 questions.
- 22 questions représentatives, dont les 17 premiers exercices des nouveaux chapitres et cinq cas existants, testées avec une bonne puis une mauvaise réponse : 44 soumissions réelles au moteur, toutes annulées.
- Réponses et corrections cachées par la RPC avant validation ; corrections renvoyées après soumission.
- Minimum de dix exercices par chapitre, cours de plus de 1000 caractères et sources non vides.
- Quatre options, une seule correcte, explication et URL pour chacune des 280 questions.
- Aucun doublon textuel dans le parcours S1.
- Retour arrière testé : restitue les rubriques et rattachements précédents.
- Contrôles de comptage après publication.
- Pas de recette visuelle navigateur ni de déploiement frontend pour ce lot.

## Retour arrière
Ordre en cas d'annulation de toute la campagne : finalisation → suite → premier lot.
Le rollback de finalisation désactive les nouveaux éléments au lieu de les supprimer. Il préserve les références des tentatives.
Attention : si des tentatives ont été enregistrées après publication sur les trente questions réaffectées, leurs topic_id historiques nécessitent une analyse avant restauration du rattachement ; le script ne réécrit pas les tentatives utilisateur.
