# Sauvegarde et reprise Leryko

État au 15 octobre 2026 : offre Supabase gratuite, aucune sauvegarde automatique de plateforme incluse. Les sauvegardes de base Supabase n'incluent jamais les fichiers Storage. Aucun exercice complet de restauration de base n'est encore validé.

## Outils préparés

- `node scripts/backup-database.mjs` : export PostgreSQL custom complet, chiffrement AES-256-GCM avec clé dérivée par scrypt, vérification du déchiffrement avant écriture. Aucune copie SQL en clair sur disque. Nécessite `pg_dump` 17+, `PGHOST`, `PGUSER`, `PGDATABASE`, `PGPORT`, `PGPASSFILE`, `PGSSLMODE=verify-full` et le certificat racine officiel dans `PGSSLROOTCERT`. Ne pas placer le mot de passe dans une commande, Git ou une conversation.
- `node scripts/backup-storage.mjs` : copie paginée de tous les buckets, fichiers chiffrés individuellement et manifeste chiffré. Nécessite `SUPABASE_URL` et une clé serveur `SUPABASE_SERVICE_ROLE_KEY`, jamais une variable `VITE_*`.
- Pour les deux : `LERYKO_BACKUP_DIRECTORY` désigne une destination privée hors site et `LERYKO_BACKUP_PASSPHRASE` une phrase secrète de 20 caractères minimum conservée séparément. Les chemins et le contenu ne sont pas publiés dans les sorties des outils.
- `node scripts/check-backup.mjs <dossier-storage>` : vérifie hors ligne chaque déchiffrement, taille et SHA-256. Ne remet aucune donnée en production.
- `node scripts/snapshot-course-library.mjs <manifest-migration> <nouveau-dossier>` : copie locale vérifiée des PDF sources. La copie du 15 octobre comporte 24 PDF et 74 831 569 octets. Elle ne couvre ni les comptes, ni les avatars, ni la base, ni une panne du PC.

Les tests unitaires prouvent le chiffrement/déchiffrement et le rejet d'une mauvaise clé ou d'un fichier altéré. Ils ne prouvent pas la restauration PostgreSQL.

## Conditions pour activer l'automatisation

Choisir une destination hors site et y tester l'accès. Installer le client PostgreSQL officiel, configurer les secrets dans un gestionnaire local ou un ordonnanceur privé, puis exécuter les deux exports. Ne jamais déposer les sauvegardes, les mots de passe, les avatars ou les dumps dans le dépôt public ni dans les artifacts GitHub.

Objectif proposé : une sauvegarde quotidienne et sept générations conservées, puis adaptation après mesure et validation par l'éditeur. Aucun délai de restauration garanti avant un exercice mesuré. La copie Storage n'est pas transactionnelle : utiliser une fenêtre calme et réconcilier les objets créés/modifiés pendant l'export avec les métadonnées de base.

## Exercice de restauration obligatoire

1. Provisionner un projet de test séparé ou un environnement Supabase local. Désactiver ses envois e-mail, cron, webhooks et intégrations externes avant import. Aucun message ni traitement de production ne doit partir de cette copie.
2. Restaurer selon le guide officiel Supabase, en distinguant les schémas gérés (`auth`, `storage`, extensions) du schéma applicatif. Ne pas exécuter aveuglément `pg_restore --clean` sur un projet Supabase hébergé et jamais sur la production.
3. Restaurer les binaires par l'API Storage avec leurs chemins et buckets. La table `storage.objects` seule ne restaure pas un PDF.
4. Vérifier les nombres de lignes, les contraintes, droits, fonctions et SHA-256 des fichiers, puis les parcours connexion, quiz, progression et lecture PDF.
5. Réconcilier les comptes supprimés après la date de sauvegarde et les demandes de droits avant toute remise en service ; ne pas réactiver des personnes purgées.
6. Relever la durée, les pertes éventuelles et les erreurs. Tant que cette étape n'a pas réussi, la reprise complète reste non validée.

Références : https://supabase.com/docs/guides/platform/backups et https://supabase.com/docs/guides/platform/migrating-within-supabase/backup-restore
