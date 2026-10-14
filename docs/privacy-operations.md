# Confidentialité Leryko : décisions et mise en œuvre

Décision du propriétaire, 14 octobre 2026 : supprimer les comptes après 24 mois d’inactivité, avec avertissement préalable. Un préavis de 30 jours est retenu dans le texte préparé. Éditeur et responsable du traitement : Stéphan Gury, stephangury@gmail.com.

La page `/informations` présente les traitements constatés dans le code, les droits, les prestataires, les photos publiques, le stockage local et les limites actuelles de conservation. Le mécanisme automatique est déployé dans Supabase, mais les envois et suppressions sont suspendus : aucun domaine n’est encore vérifié dans Resend et aucune clé d’envoi n’est configurée dans Vault. Aucun compte actuel n’a atteint 24 mois d’inactivité. Aucun avertissement n’a été envoyé et aucun compte réel n’a été supprimé pendant cette mise en place.

## Traitement installé

La fonction Edge `account-retention` est appelée chaque jour par le job Supabase `leryko-account-retention-daily` à 03:10 UTC. Elle est authentifiée par un ticket aléatoire à usage unique, valable deux minutes, enregistré seulement sous forme de SHA-256 dans un schéma privé. Une reprise du même ticket est refusée. Le ticket n’autorise que ce traitement fixe ; l’appelant ne peut pas choisir un compte ou modifier les délais. Les clés Supabase et Resend ne sont jamais placées dans la file réseau ni transmises au navigateur. Le bail de traitement empêche deux exécutions simultanées et expire après dix minutes.

L’activité est le maximum de la création, de la dernière connexion, de `last_seen_at` et de la création/du rafraîchissement des sessions. L’application enregistre aussi une activité à son ouverture et à son retour au premier plan. Les comptes étudiants avec adresse confirmée sont candidats après 24 mois. Les administrateurs, comptes anonymes/SSO, comptes sans profil et comptes portant `app_metadata.retention_exempt=true` sont exclus du traitement automatique ; les cas incomplets nécessitent un examen manuel.

Les avertissements utilisent une clé d’idempotence persistante. Un envoi incertain datant de plus de vingt heures est bloqué pour éviter un doublon après expiration de l’idempotence du prestataire. Le worker vérifie l’identifiant du message, son destinataire et son dernier événement via l’API Resend. Le délai minimal de 30 jours commence à l’observation de la remise, pas à la mise en file. La remise est revérifiée avant de réclamer une suppression. Un rebond, une plainte ou un échec suspend la procédure. Les lectures du prestataire doivent être possibles avec la clé configurée.

La reprise d’activité annule les notices tant que la suppression n’a pas été réclamée. La réclamation verrouille les lignes Auth/profil, contrôle à nouveau l’éligibilité et le préavis, révoque les sessions, puis bloque les nouvelles connexions, activités et photos concurrentes. Le worker bannit temporairement l’identité en cours de suppression, supprime les fichiers `avatars/<user_id>/` via Storage, puis supprime l’identité avec l’API Auth d’administration ; les relations de profil et progression sont supprimées par leurs clés étrangères. Les fichiers possédés hors de cet espace placent le dossier en examen manuel, pour protéger les contenus partagés. Les suppressions partielles restent en état `deleting` et sont reprises, sans rendre le compte de nouveau accessible. Les JWT d’accès déjà émis restent cryptographiquement valides jusqu’à leur expiration ; les sessions de rafraîchissement sont supprimées et les profils/données applicatives sont retirés lors de la purge.

## Activation après configuration de l’e-mail

1. Vérifier un domaine d’envoi dans Resend avec ses enregistrements DNS. Aucun abonnement ou domaine n’a été acheté par cette mise en place.
2. Configurer dans Supabase Vault `leryko_retention_from` (expéditeur vérifié) et `leryko_retention_resend_api_key` (clé serveur permettant l’envoi et la lecture des messages). Ne jamais saisir les clés dans un fichier Git, une conversation ou la page publique.
3. Vérifier le contenu du message et la remise sur une identité factice dédiée avec un traitement contrôlé. La remise réelle et l’API de suppression ne peuvent pas être vérifiées de bout en bout tant que l’expéditeur est absent. Ne pas raccourcir les délais pour des comptes existants.
4. Exécuter `select retention.invoke_worker();` avec les droits d’administration, puis vérifier `select last_run_at,last_result from retention.worker;`. La configuration des deux secrets active les traitements lors des appels suivants ; il n’y a pas de bouton dans le navigateur.
5. Pour suspendre tous les traitements, désactiver le job avec `cron.alter_job` après consultation de l’aide actuelle de Supabase Cron. Pour protéger un compte, définir `app_metadata.retention_exempt=true` côté administration Auth et, si une notice existe, ajouter un `hold_reason` à sa ligne privée. Ne pas utiliser les métadonnées modifiables par l’utilisateur.

## Vérifications effectuées

Sept tests unitaires du worker et trois tests de pagination passent. La suite SQL, entièrement enveloppée dans BEGIN/ROLLBACK et limitée à des identités générées `example.invalid`, vérifie les exclusions, l’absence de suppression avant remise et préavis, l’annulation par activité/session, les blocages Storage, les activités tardives, les baux expirés et les tickets expirés/réutilisés. Zéro identité factice conservée. Le premier appel réel du worker retourne HTTP 200 avec `configured=false`, zéro e-mail et zéro suppression. Les wrappers de rétention ne sont pas exécutables par les rôles `anon` et `authenticated`.

Migrations de production : `20261014200936_account_retention.sql`, `20261014201236_retention_one_time_invocations.sql` et `20261014201728_retention_social_cleanup.sql`. La seconde remplace un jeton réutilisable par des tickets à usage unique : les droits du schéma réseau géré par la plateforme ne permettent pas de supposer que la file sortante est privée. La troisième supprime aussi les notifications liées aux amitiés et défis du compte chez les autres destinataires, avant les suppressions en cascade, sans toucher leurs autres notifications. Cette dernière propriété est vérifiée par des fixtures SQL entièrement annulées.

## Suivi et cas nécessitant l’éditeur

1. Mesurer la dernière activité comme le maximum des dates de création, de connexion Supabase et d’activité réelle (`profiles.last_seen_at`). Une valeur manquante ne suffit jamais à déclarer un compte inactif. Vérifier la couverture des événements d’activité et exclure les comptes administrateurs ou techniques du traitement automatique.
2. Établir une liste interne de candidats atteignant 24 mois d’inactivité. Faire vérifier cette liste par l’éditeur ; ne pas exporter les adresses dans un dépôt public.
3. Envoyer un message individuel de gestion du compte, distinct des rappels facultatifs de révision, avec la date envisagée de suppression et un lien normal vers l’application. Conserver la preuve de remise du message ; une simple mise en file ou un appel HTTP réussi n’est pas une preuve de remise.
4. Accorder au moins 30 jours après l’avertissement. En cas d’échec de remise, suspendre la suppression et examiner le dossier. Ne jamais supprimer sur le seul fondement d’un avertissement non remis.
5. Avant toute suppression, vérifier à nouveau l’activité, sous protection contre les accès concurrents. Toute nouvelle activité annule la procédure. Vérifier également les demandes de portabilité, limitations et obligations de conservation en cours.
6. Purger les photos et les autres objets Storage concernés : supprimer une identité Auth ne suffit pas à supprimer ses fichiers. Examiner toutes les relations et les éventuelles données sociales partagées avant la suppression du compte via l’API d’administration. Révoquer les sessions et vérifier l’absence de données orphelines.
7. Documenter le sort des copies de sauvegarde et empêcher qu’une restauration réintroduise durablement les comptes supprimés. Garder seulement la preuve minimale de traitement nécessaire, avec une durée définie.

Le mécanisme couvre ces contrôles, hormis la définition des durées de sauvegarde, les garanties de restauration et la revue humaine des dossiers bloqués. Ne pas programmer une suppression SQL brute d’`auth.users`.

## Demandes de droits

Réception à l’adresse publique de l’éditeur ; vérifier l’identité de manière proportionnée, sans demander de mot de passe. Répondre dans un mois, ou notifier dans ce délai une prolongation légalement justifiée. Examiner les données Auth, profil, cursus, réponses, progression, relations sociales, signalements, journaux et photos. Ne jamais inclure des données d’un autre utilisateur dans un export. Suivre une demande jusqu’au contrôle effectif de son exécution.

## Paramètres restant à vérifier

- Fixer et appliquer les durées de purge des signalements, journaux Supabase/Sentry, journaux d’e-mails et sauvegardes ; vérifier les valeurs réellement disponibles dans les abonnements.
- Vérifier les contrats de sous-traitance effectivement applicables à Supabase, Cloudflare, Sentry et Resend, leurs sous-traitants et les garanties de transfert. L’emplacement européen de la base ne suffit pas à établir une résidence européenne de toutes les données.
- La boîte Gmail de contact reçoit aussi des données personnelles lors des demandes d’assistance : documenter son accès, sa sécurité et la durée de conservation des demandes.
- Évaluer et documenter l’intérêt légitime du diagnostic technique et de la sécurité, ainsi que la visibilité effective des données dans les fonctions sociales.
- La révocation de l’ancien jeton GitHub a été confirmée par le propriétaire. La protection Supabase contre les mots de passe compromis reste à vérifier dans les paramètres du projet.

## Références

- Information des personnes : https://www.cnil.fr/fr/conformite-rgpd-information-des-personnes-et-transparence
- Droits : https://www.cnil.fr/fr/passer-laction/les-droits-des-personnes-sur-leurs-donnees
- Conservation : https://www.cnil.fr/fr/passer-laction/les-durees-de-conservation-des-donnees
- La règle de 24 mois est un choix du propriétaire pour Leryko ; elle n’est pas présentée comme une durée universelle imposée par la CNIL.
