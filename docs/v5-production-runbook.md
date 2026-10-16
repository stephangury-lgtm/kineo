# Bascule V5 et retour arrière

## État de préparation

La V5 et l’interface actuelle restent dans le même code, sans migration de base ni changement des services. La valeur par défaut reste l’interface actuelle. Préparer les versions ne les publie pas. Les tests navigateur utilisent des identités synthétiques et interceptent les API.

Une branche de sauvegarde `backup/leryko-production-before-v5-2026-10-16` conserve le commit `734606ddc56a06ec4466257432bec62290579acf`, identifié dans le `version.json` public de production le 16 octobre 2026. Cette branche conserve les sources ; elle ne sauvegarde pas la base de données ni l’identifiant de version Cloudflare. Ce dernier sera capturé par le workflow immédiatement avant la publication.

La recette connectée complète reste à terminer. Le projet `leryko-v5-staging` (`cyzdivbdgpvhwpmikeqh`, région `eu-west-1`) est créé et le schéma restreint installé après autorisation explicite du propriétaire. Cinq suites SQL passent sur des données synthétiques : isolation, régressions d’accès et réponses, challenge quotidien, rétention et scénarios des trois cursus. L’authentification HTTP, le stockage de PDF et la recette navigateur connectée restent à valider selon `docs/staging.md`. Ne pas remplir les variables d’acceptation ci-dessous avant la recette complète.

## Cohérence des trois cursus

Kiné France, Kiné Espagne et IFSI partagent les cinq entrées, le cadre de l’accueil (prochaine action, cours, progression), les cartes et les boutons. Les libellés sont adaptés en espagnol pour Kiné Espagne. Les niveaux restent propres à chaque cursus : K2–K5, ES1–ES4 et semestres IFSI. Les fonctionnalités France ne sont pas artificiellement proposées aux autres cursus : leur historique détaillé renvoie vers les statistiques de leur cursus, et Réviser évite les appels de reprise/historique du moteur France.

La recette doit couvrir les trois cursus et leurs droits respectifs. Les tests visuels contrôlent une navigation à cinq onglets sur une seule ligne, l’absence de débordement horizontal à 320, 390 et 1 024 pixels, le cadre commun et les principaux accès sur les trois moteurs. Cela ne remplace pas la validation du contenu ni des écritures réelles de chaque cursus.

## Trois niveaux de retour arrière

1. Dans une construction V5, l’utilisateur choisit « Interface actuelle » dans le bandeau. `/?ui=legacy` force aussi ce choix pour la session du navigateur. Les deux présentations utilisent le même compte et les mêmes données. Ce retour ne rétablit pas un ancien moteur applicatif.
2. Le workflow **Restore an exact Leryko Cloudflare version** restaure le code et les assets d’une version Cloudflare précise. Utiliser le `version` UUID, le `commit` complet et l’`interface` contenus dans `release-before.json`. Ne pas confondre l’UUID de déploiement et celui de version. Choisir la branche main. Le workflow vérifie le commit complet, l’interface, les routes, les assets et le service worker après restauration.
3. Les sources Git et les artefacts des deux variantes sont conservés. Chaque artefact contient `version.json` et un manifeste SHA-256 vérifiant tous les fichiers. Les artefacts GitHub expirent après 90 jours : télécharger et conserver hors GitHub les versions que l’on veut garder plus longtemps. Un manifeste de sommes de contrôle n’est pas une signature d’authenticité.

Un retour de code n’annule pas les réponses, notes, invitations ou autres écritures faites entre-temps. Aucune migration n’est incluse dans ce changement ; une future migration devra avoir sa propre stratégie de sauvegarde et de compatibilité.

## Préparer les candidats

`npm run release:prepare` construit et vérifie `release-candidates/legacy` et `release-candidates/v5`, sans publication. La V5 exige `VITE_ENABLE_V5_PREVIEW=true` et `VITE_V5_DEFAULT=true`. Sans ces variables, la construction reste legacy. Chaque variante a un cache PWA distinct, même à commit identique.

`npm run test:rollback` utilise un serveur exclusivement local sur 127.0.0.1:4180. Il simule ancienne interface → V5 → ancienne interface avec un vrai service worker, vérifie les caches et la navigation, sans demander de rollback Cloudflare. Ce contrôle local ne prouve pas qu’un token Cloudflare a les droits nécessaires en production.

Le workflow **Prepare reversible Leryko releases** prépare les deux variantes à partir du commit effectivement construit dans la CI. Il contrôle les régressions, la V5 sur trois moteurs et la simulation PWA de retour arrière. Pour un artefact de PR, `version.json` décrit le commit de construction de la PR ; ce n’est pas une validation du futur commit de fusion sur main. Une construction locale avec des modifications non commitées sert uniquement aux essais locaux, pas à une publication.

## Conditions avant activation réelle

- Terminer la recette sur un backend distinct selon `docs/staging.md` : connexion/déconnexion, profil et cursus, reprise et fin de quiz, corrections d’examen, notes et favoris, lecture PDF, recherche/invitations/défis, rôles et publication administrateur. Utiliser des données synthétiques et contrôler les écritures dans la base de test.
- Faire valider les écrans mobiles et le parcours par le propriétaire, puis conserver le compte rendu et le SHA testé.
- Vérifier une sauvegarde restaurable des données selon les procédures existantes. Le rollback de frontend ne remplace pas une restauration de données.
- Configurer un seul système de publication de production. Le dépôt dispose aussi d’une intégration **Workers Builds** : désactiver sa publication automatique de main si GitHub Actions devient le déployeur. Le verrou GitHub ne bloque pas un déploiement externe Cloudflare. Ne pas supprimer les anciennes versions Cloudflare nécessaires à la restauration.
- Vérifier les permissions du token Cloudflare pour lire les déploiements, publier et restaurer une version. Les secrets restent dans GitHub, jamais dans les artefacts. Configurer les règles de l’environnement GitHub `production` et ses approbateurs selon les possibilités du compte.
- Répéter sur le Worker de test le déploiement et la restauration Cloudflare réels. Le test local vérifie la PWA ; l’exercice sur Cloudflare valide l’accès aux versions et les droits de restauration.

## Activer sur main après recette

La PR reste soumise aux protections de main et aux contrôles obligatoires. Aucun contournement et aucune fusion automatique ne sont ajoutés.

Le 16 octobre 2026, après confirmation d’identité du propriétaire, les deux contrôles `candidate (legacy)` et `candidate (v5)` ont été ajoutés et vérifiés dans les protections de main, en complément de `build` et `CodeQL`. Pull request, branche à jour, résolution des conversations et absence de contournement administrateur restent imposées. Les fichiers YAML seuls ne modifient pas ces règles.

Après validation du commit précis sur main, renseigner les variables GitHub :

| Variable | Valeur et rôle |
| --- | --- |
| `LERYKO_PRODUCTION_INTERFACE` | `legacy` par défaut ; `v5` après décision de bascule |
| `LERYKO_V5_ACCEPTANCE_SHA` | SHA complet du commit réellement testé et accepté |
| `LERYKO_SINGLE_DEPLOYER_CONFIRMED` | `true` seulement après vérification du déployeur unique |

Lancer **Deploy Kineo to Cloudflare** sur main, avec `interface=v5` (ou `inherit`). La V5 est refusée si le SHA accepté diffère du commit à publier. Toute modification ultérieure nécessite une nouvelle validation de son SHA. Le choix manuel `legacy` permet une publication de l’ancienne présentation sans réactiver la V5. Pour les futurs déploiements hérités après un retour arrière, remettre aussi `LERYKO_PRODUCTION_INTERFACE=legacy` afin d’éviter une réactivation ultérieure.

Avant publication, le workflow capture la version Cloudflare actuellement à 100 % et l’identité du frontend public, archive cette cible avec le build, puis vérifie qu’aucun autre déploiement n’est intervenu. Il refuse une répartition de trafic entre plusieurs versions. La publication est suivie de contrôles du SHA et de l’interface. En cas d’échec de publication ou des contrôles, il tente la restauration de l’UUID capturé et vérifie le résultat. Un workflow rouge ou une annulation nécessite de lire les étapes : ne pas supposer que la restauration a réussi. Une annulation manuelle peut empêcher le rollback automatique ; utiliser le workflow de restauration si nécessaire.

## Après la bascule

Contrôler la connexion et un parcours réel autorisé, surveiller les workflows de santé existants, les erreurs applicatives et les retours utilisateurs. Vérifier également une installation PWA déjà utilisée sur téléphone. Garder le compte rendu du déploiement et son artefact `release-before.json`. Le comportement sur des appareils hors ligne reste lié à leur reconnexion et à la mise à jour du service worker.
