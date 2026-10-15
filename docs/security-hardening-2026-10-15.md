# Durcissement Leryko — 15 octobre 2026

## Modifications appliquées en base

- Retrait de TRUNCATE, REFERENCES et TRIGGER pour PUBLIC, anon et authenticated sur les tables publiques. Avant correction : 47 tables avec TRUNCATE pour anon et 49 pour authenticated. RLS ne couvre pas TRUNCATE ; aucun effacement n'a été exécuté pour le tester.
- Restriction des privilèges par défaut pour les nouvelles tables/fonctions créées par postgres. Les autres propriétaires de schémas gérés restent sous contrôle de la plateforme.
- Quotas atomiques côté base : 20 créations de sessions/minute, 30 demandes d'amitié/heure, 30 signalements/heure, 20 erreurs client/heure, 60 écritures de notes/minute, 240 réponses de cursus/minute. Ces limites ne remplacent pas un contrôle réseau et ne bloquent pas toutes les lectures abusives.
- Compteurs privés sans contenu, supprimés quotidiennement lorsqu'ils ont plus d'un jour (conservation maximale proche de 48 heures). RLS activée, aucun accès client.
- Contrôle de sécurité enrichi : droits TRUNCATE, RLS, fonctions privilégiées anonymes, chemins de recherche et caractère privé des cours.
- Défi quotidien de cursus : explications masquées jusqu'à la fin du défi. Test SQL dédié vérifiant le masquage initial et leur restitution après les cinq réponses validées.
- Surveillance opérationnelle dans un schéma privé : worker de rétention, erreurs cron récentes, fichiers de cours manquants. Vérification réservée au serveur avec un résultat booléen, accessible aux seuls workflows GitHub explicitement autorisés par OIDC.

Le contrôle automatique avait rejeté une première proposition exposant des métriques opérationnelles anonymement. Cette proposition a été abandonnée au profit du schéma privé ; aucune publication de ces détails n'a été appliquée.

## Authentification et publication

La protection de main est créée : pull request obligatoire, test `build`, branche à jour, conversations résolues, application aux administrateurs, aucune autorisation de force push/suppression. L'approbation d'une seconde personne n'est pas imposée au propriétaire seul.

Supabase : confirmation d'e-mail activée ; connexions anonymes désactivées ; limites de connexion existantes vérifiées. Politique renforcée à 12 caractères pour les nouveaux mots de passe et connexion récente requise pour les changements. Les anciens mots de passe ne sont pas invalidés par cette nouvelle longueur minimale. Détection des mots de passe compromis indisponible sur l'offre gratuite.

Le broker de comptes factices exige un workflow et une branche autorisés. Le nettoyage utilise app_metadata, non modifiable par l'étudiant, le numéro d'exécution GitHub et le format d'adresse factice ; il ne peut pas viser un compte réel en modifiant user_metadata. Trois anciens comptes factices préexistants sont à examiner séparément ; ils n'ont pas été supprimés sur la seule foi de leurs métadonnées éditables.

Le code ajoute CSP/HSTS, épingle les versions npm déjà résolues, prépare Dependabot, bloque les dépendances à risque élevé et exécute les tests navigateur avant publication. Les parcours authentifiés deviennent quotidiens, en plus des contrôles après déploiement. Notifications GitHub existantes : interface et e-mail, échecs uniquement. La remise d'une alerte dans la boîte du propriétaire reste à confirmer.

## Vérifications et limites

Une seconde passe a corrigé le blocage des PDF par le chargement des notes/favoris : catalogue indépendant, délai de 12 secondes, reprise et annulation des requêtes abandonnées. Le scénario est vérifié sur Chromium, Firefox et WebKit.

Les traces, vidéos et captures des tests connectés de production ne sont plus publiées en artifacts : elles peuvent contenir des jetons ou liens signés. Un contrôle préalable PostgREST et une politique restrictive Storage exigent un profil encore présent, même si la signature du JWT n'a pas encore expiré. Les liens de téléchargement signés déjà émis restent utilisables jusqu'à leur expiration. Un scénario CI dédié utilise une connexion normale au compte factice du run, supprime ce compte par le broker autorisé puis vérifie les refus Data API et Storage sans publier le jeton.

Les suites SQL s'exécutent en transaction annulée, avec comptes générés pour les tests. Contrôles de deux comptes sur profils, notes, notifications et sessions ; impossibilité de transférer une note, de publier comme étudiant ou d'attribuer directement des XP. Tests de cursus, masquage des réponses, PDF privés et garde-fous de rétention rejoués.

Audit npm du 15 octobre : zéro vulnérabilité signalée. Son résultat est ponctuel. Sonde publique : 20 requêtes, concurrence 4, zéro échec, p95 513 ms. Cette sonde ne mesure pas la capacité avec des étudiants connectés.

L'inventaire recense 80 fonctions SECURITY DEFINER accessibles à authenticated. Le classement statique et les tests ciblés ne remplacent pas une revue indépendante de chaque fonction et de ses dépendances ; les avertissements correspondants restent visibles dans Supabase.

## Travail nécessitant encore configuration ou action du propriétaire

- Double authentification : absente sur GitHub et Supabase lors de la lecture des réglages ; enrôlement à effectuer par le propriétaire. Cloudflare demandait une connexion, contrôle encore en attente. Sécurité Gmail à vérifier par le propriétaire.
- Sauvegarde complète quotidienne hors site et exercice de restauration : destination et accès PostgreSQL/Storage manquants. Outils chiffrés préparés, copie locale des 24 PDF vérifiée ; aucune prétention de sauvegarde complète ou de reprise validée. Voir `backup-and-recovery.md`.
- Environnement de test : fichiers préparés uniquement, conformément au choix du propriétaire ; voir `staging.md`.
- Domaine d'envoi absent : ni avertissement ni suppression pour inactivité activés. Le worker quotidien indique configured=false, sans erreurs.
- SMTP Supabase personnalisé désactivé : les confirmations d'inscription et réinitialisations destinées au public restent à configurer et tester ; le service SMTP de test limite les destinataires à l'équipe du projet (https://supabase.com/docs/guides/auth/auth-smtp).
- Durées et purges des autres journaux, signalements, assistance et sauvegardes : décisions et configurations restantes. Les textes publics ne doivent pas promettre une purge qui n'existe pas.
- Test de charge authentifié et revue indépendante avant ouverture large : à réaliser sur l'environnement de test.


