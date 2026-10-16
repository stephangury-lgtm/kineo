# V5 React : premier portage réversible

Branche dédiée, pas de publication de production. L'interface actuelle reste la valeur par défaut. Aucune migration et aucun changement de permissions.

Activer `VITE_ENABLE_V5_PREVIEW=true` avant construction, puis ouvrir `/?ui=v5`. Ajouter `VITE_V5_DEFAULT=true` uniquement pour le candidat avec V5 par défaut. Le sélecteur permet de revenir immédiatement à l'interface actuelle, tout comme `/?ui=legacy`. Le choix est limité à la session du navigateur ; une construction sans le drapeau d’activation ignore le choix et le paramètre d'URL. Les routes et les écrans existants restent accessibles.

Attention : cette V5 React utilise les API réelles du backend configuré, contrairement au prototype Sites à données fictives. Ne pas publier une prévisualisation connectée à la production pour des essais de saisie. L'environnement Supabase isolé n'a pas été créé, conformément au choix antérieur. Les tests automatisés interceptent toutes les requêtes Supabase et utilisent uniquement des identités fictives.

Ce portage comprend la navigation à cinq entrées, l'accueil France avec priorité à la reprise et chargements indépendants, une entrée de parcours propre aux autres cursus, un espace Progrès, la flamme issue du serveur et les liens contextuels vers cours/notes. Communauté sépare Amis, Invitations et Défis. Le profil facilite l’accès aux résultats, au lien ami et à l’administration selon le rôle. L’administration regroupe ses accès et propose le lien public de l’application à partager. Les services, moteurs de quiz et contrôles d’accès existants sont conservés. La recette connectée reste nécessaire ; ne pas présenter les seuls tests à API simulées comme une validation de production.

Validation V5 : construire avec le drapeau, servir sur 4173, puis `LERYKO_TEST_V5=1 npx playwright test tests/e2e/v5-interface.spec.mjs`. Validation de non-régression : construire sans le drapeau et exécuter les suites existantes. Le sélecteur change uniquement l'interface, jamais les rôles, les autorisations ou la base.

Avant publication réelle : baseline et migrations de staging, profils synthétiques des cursus, documents de test, recettes connectées sur trois moteurs, audit des permissions, tests de reprise et validation utilisateur. Un retour au code ancien ne restaure pas les données ; ici aucune modification du schéma n'est prévue.

## Finalisation du lot de navigation

Dans Réviser (France), la vérification de la séance en cours précède les modes. Un échec propose une nouvelle tentative et masque les lancements jusqu’à résolution ; une attente de plus de 12 secondes est traitée comme un échec. Une séance trouvée dispose d’une action de reprise avant les autres choix. Aucun quiz ne démarre automatiquement. Les écrans métier existants, dont amis et administration, restent accessibles avec leurs contrôles habituels.

La validation automatisée couvre les parcours V5 sur Chromium, Firefox et WebKit, avec API interceptées. Elle ne remplace pas une recette connectée sur staging. Le prototype Sites conserve des données fictives ; cette PR ne le transforme pas en application connectée.

## Retour cours → révision (16 octobre 2026)

En V5 France, une révision reste montée en mémoire pendant la consultation d’un parcours, d’une leçon, de la bibliothèque ou d’un PDF. « Retour à ma révision » retrouve la même question, la sélection non validée ou la correction reçue du serveur, sans nouvelle soumission et sans recharger le questionnaire. Après une correction hors examen, un lien ouvre la leçon d’origine si le quiz a été lancé depuis celle-ci ; sinon il ouvre le parcours, sans inventer de correspondance pédagogique. Les liens de documents depuis une leçon restent utilisables.

Cette continuité est limitée à l’onglet et au montage de l’espace authentifié. Une actualisation, une déconnexion, un changement de cursus ou le retour à l’interface actuelle libère la vue conservée. Aucun brouillon ni correction n’est écrit dans localStorage/sessionStorage. La reprise serveur existante reste la référence après actualisation ; elle ne garantit pas la restauration d’une sélection non envoyée. Le choix V5 lui-même reste mémorisé pour la session du navigateur.

La vue conservée est masquée pendant la lecture. Un autre identifiant de séance ou changement de paramètres recrée son écran. En examen, la correction et le raccourci vers les cours restent absents avant la fin, même si une réponse API contient une correction. Les contrôles AuthGate et RevisionContentGate sont conservés. Aucun changement de schéma, de droits ou de service Supabase.

La préparation des deux variantes, la conservation des artefacts, les contrôles PWA et les procédures Cloudflare sont décrits dans `docs/v5-production-runbook.md`. La préparation ne constitue ni un déploiement ni un exercice Cloudflare réel.
