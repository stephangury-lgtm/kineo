# Premier contrôle quotidien — 18 octobre 2026

## File de production consultée

144 signalements : 96 résolus, 23 nouveaux et 25 examinés sans clôture. L'instantané JSON associé contient les identifiants et chemins nécessaires au suivi, sans identité ni adresse e-mail des auteurs. Les anciens signalements examinés ne sont pas considérés résolus par défaut.

## Premier lot de corrections

Branche : `codex/feedback-audit-2026-10-18`.

| Signalement | Diagnostic et correction préparée |
|---|---|
| 96071eff-6bc9-4239-95fb-ecff692b23c6 | Des caractères `$` étaient placés hors des expressions JSX du compteur de questions fragiles. Retrait des caractères parasites. |
| fb7c5c44-954f-4785-975a-8703cf0ddd59 | Retrait de la flamme décorative du bandeau de préparation quotidienne ; la série du compte reste visible dans l'en-tête. |
| 2ec8cc27-46c1-4e5d-bd78-642e98b93e7a et 72af5079-6297-465a-9cc0-c6492881a915 | Un seul accès à la collection de badges dans Progrès, au lieu de deux. |
| ec2907a7-5922-4947-80ef-2b388fc4a137 | La recherche renvoyait aussi les amis et invitations existants. Filtrage de ces trois groupes dans les résultats. Le serveur refuse déjà une relation supplémentaire : aucune modification des droits ni des relations en base. |
| e3183b47-a403-4574-88bc-7a58ece7928b | En-tête du profil compacté, illustration décorative retirée ; mêmes règles pour les trois cursus. |
| 59bd279f-2cfa-4fc0-85cb-9edeef5cfba5 | Réinitialisation du défilement lors d'un changement de chemin, notamment de la liste des cours vers une leçon. Les changements de paramètres du quiz ne déclenchent pas cette réinitialisation. |

Les corrections restent à publier et les retours restent ouverts en production jusqu'à vérification de la publication. Ce lot ne clôture pas les 48 retours en attente.

## Points à poursuivre

- PDF `b0faff17-ae7b-4136-89f7-57df78d6e62b` : métadonnées et objet Storage présents, statut validé, MIME PDF et taille cohérents (1 880 274 octets). La présence du fichier ne prouve ni son affichage ni sa validité binaire. Contrôler l'ouverture avec un compte autorisé et le lecteur mobile ; ne pas déclarer le signalement résolu.
- Qualité pédagogique : examiner les sessions signalées pour les questions répétitives, ambiguës, les distracteurs trop simples et les explications insuffisantes.
- Réponses rédigées : vérifier le mécanisme de correction et les formulations acceptées avant toute modification des critères d'évaluation.
- Suggestions sur la révision espacée, les badges thématiques et le cours suivant : confronter aux fonctionnalités actuelles avant décision.
- Anciennes régressions déjà examinées : revalider individuellement avant clôture ; plusieurs correctifs existent déjà dans le code actuel (filtres de correction, mélange des options et reprise des séances notamment).

## Vérification

- Compilation TypeScript et Vite réussie.
- 28 tests unitaires réussis.
- 15 vérifications ciblées réussies sur Chromium, WebKit et Firefox : accès unique aux badges et défilement sur les trois cursus, filtrage des amis et invitations, compteur sans caractères parasites et retrait de la flamme décorative.
- Contrôle des invariants du code réussi et 13 contrats de refus d'accès anonymes réussis en production.
- Suite V5 existante : résultats consignés dans la description de la pull request après exécution complète.
- Aucun envoi d'e-mail, aucune modification des données des apprenants, aucune publication en production pendant ce contrôle.
