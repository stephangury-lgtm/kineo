# Refonte visuelle anatomique — état consolidé

Date : 2026-10-04

## Snapshot live vérifié

La base live contient actuellement 61 questions publiées avec `image_url` et 17 hashes d'images distincts. Le snapshot antérieur de 63 questions / 16 visuels a donc évolué entre-temps. Les 61 questions actuelles appartiennent toutes aux quatre périmètres prioritaires :

- Hanche : 14 questions / 3 visuels actuels
- Genou : 16 questions / 5 visuels actuels
- Cheville : 15 questions / 5 visuels actuels
- Pied : 16 questions / 4 visuels actuels

## Refonte cible préparée

Les mappings question → visuel ont été reconstruits directement depuis la base live et les supports IFMK validés :

- Hanche : 11 familles visuelles cibles
- Genou : 10 familles visuelles cibles
- Cheville : 9 familles visuelles cibles
- Pied : 13 familles visuelles cibles

Cela représente 43 familles visuelles potentielles pour 61 questions, avec réutilisation uniquement lorsque la même vue anatomique est réellement pertinente pour plusieurs questions.

## Assets préparés hors production

Les figures anatomiques ont été extraites directement des PDF IFMK quand une image source exploitable était embarquée. Les titres et légendes révélant les réponses ont été supprimés par recadrage. Cas particulier : le visuel de l'angle cervico-diaphysaire a été préparé avec le texte `130°` masqué afin que l'image ne donne pas la réponse.

Aucune `image_url` live n'a encore été remplacée. Aucun hotspot archivé n'a été republié.

## Interaction hotspot

Le défaut de calcul des coordonnées reste confirmé dans `RevisionPage.tsx` : la position est actuellement calculée depuis le rectangle du bouton conteneur, pas depuis le rectangle réel de l'image, et l'API utilise un `MouseEvent`/`onClick`. Avant toute réactivation des hotspots : Pointer Events, coordonnées sur le `<img>`, clamp 0–100 et tests mobile 360/390/412 px + desktop.

## Sécurité

- Branche de travail : `visuals-anatomy-refactor-2026-10-04`
- Production Cloudflare Workers inchangée : `kineo.stephangury.workers.dev`
- Aucune mutation des années/UE non sourcées.
- Les futures écritures Supabase devront être limitées à des UUID explicites et accompagnées d'un mécanisme de rollback.
