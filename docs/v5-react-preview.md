# V5 React : premier portage réversible

Branche dédiée, pas de publication de production. L'interface actuelle reste la valeur par défaut. Aucune migration et aucun changement de permissions.

Activer `VITE_ENABLE_V5_PREVIEW=true` avant construction, puis ouvrir `/?ui=v5`. Le sélecteur permet de revenir immédiatement à l'interface actuelle. Le choix est limité à la session du navigateur ; une construction sans ce drapeau ignore le choix et le paramètre d'URL. Les routes et les écrans existants restent accessibles.

Attention : cette V5 React utilise les API réelles du backend configuré, contrairement au prototype Sites à données fictives. Ne pas publier une prévisualisation connectée à la production pour des essais de saisie. L'environnement Supabase isolé n'a pas été créé, conformément au choix antérieur. Les tests automatisés interceptent toutes les requêtes Supabase et utilisent uniquement des identités fictives.

Ce premier portage comprend la navigation à cinq entrées, l'accueil France avec priorité à la reprise et chargements indépendants, une entrée de parcours propre aux autres cursus, un espace Progrès, la flamme issue du serveur et les liens contextuels vers cours/notes. Il réutilise les services existants et les contrôles d'accès. Les modes de révision, amis, administration, quiz, leçons et bilans conservent leurs moteurs et pages actuels : leur refonte détaillée et le retour depuis un cours vers une séance en cours restent à porter et à vérifier. Ne pas présenter cette étape comme une migration complète de tous les écrans.

Validation V5 : construire avec le drapeau, servir sur 4173, puis `LERYKO_TEST_V5=1 npx playwright test tests/e2e/v5-interface.spec.mjs`. Validation de non-régression : construire sans le drapeau et exécuter les suites existantes. Le sélecteur change uniquement l'interface, jamais les rôles, les autorisations ou la base.

Avant publication réelle : baseline et migrations de staging, profils synthétiques des cursus, documents de test, recettes connectées sur trois moteurs, audit des permissions, tests de reprise et validation utilisateur. Un retour au code ancien ne restaure pas les données ; ici aucune modification du schéma n'est prévue.

## Finalisation du lot de navigation

Dans Réviser (France), la vérification de la séance en cours précède les modes. Un échec propose une nouvelle tentative et masque les lancements jusqu’à résolution ; une attente de plus de 12 secondes est traitée comme un échec. Une séance trouvée dispose d’une action de reprise avant les autres choix. Aucun quiz ne démarre automatiquement. Les écrans métier existants, dont amis et administration, restent accessibles avec leurs contrôles habituels.

La validation automatisée couvre cinq scénarios V5 sur Chromium, Firefox et WebKit, avec API interceptées. Elle ne remplace pas une recette connectée sur staging. Le prototype Sites conserve des données fictives ; cette PR ne le transforme pas en application connectée.
