# Confidentialité Leryko : décisions et mise en œuvre

Décision du propriétaire, 14 octobre 2026 : supprimer les comptes après 24 mois d’inactivité, avec avertissement préalable. Un préavis de 30 jours est retenu dans le texte préparé. Éditeur et responsable du traitement : Stéphan Gury, stephangury@gmail.com.

La page `/informations` présente les traitements constatés dans le code, les droits, les prestataires, les photos publiques, le stockage local et les limites actuelles de conservation. Elle ne présente pas la purge automatique comme opérationnelle. Aucun compte n’est supprimé par ce changement et aucun avertissement n’est envoyé.

## Procédure à mettre en place avant une purge

1. Mesurer la dernière activité comme le maximum des dates de création, de connexion Supabase et d’activité réelle (`profiles.last_seen_at`). Une valeur manquante ne suffit jamais à déclarer un compte inactif. Vérifier la couverture des événements d’activité et exclure les comptes administrateurs ou techniques du traitement automatique.
2. Établir une liste interne de candidats atteignant 24 mois d’inactivité. Faire vérifier cette liste par l’éditeur ; ne pas exporter les adresses dans un dépôt public.
3. Envoyer un message individuel de gestion du compte, distinct des rappels facultatifs de révision, avec la date envisagée de suppression et un lien normal vers l’application. Conserver la preuve de remise du message ; une simple mise en file ou un appel HTTP réussi n’est pas une preuve de remise.
4. Accorder au moins 30 jours après l’avertissement. En cas d’échec de remise, suspendre la suppression et examiner le dossier. Ne jamais supprimer sur le seul fondement d’un avertissement non remis.
5. Avant toute suppression, vérifier à nouveau l’activité, sous protection contre les accès concurrents. Toute nouvelle activité annule la procédure. Vérifier également les demandes de portabilité, limitations et obligations de conservation en cours.
6. Purger les photos et les autres objets Storage concernés : supprimer une identité Auth ne suffit pas à supprimer ses fichiers. Examiner toutes les relations et les éventuelles données sociales partagées avant la suppression du compte via l’API d’administration. Révoquer les sessions et vérifier l’absence de données orphelines.
7. Documenter le sort des copies de sauvegarde et empêcher qu’une restauration réintroduise durablement les comptes supprimés. Garder seulement la preuve minimale de traitement nécessaire, avec une durée définie.

Cette procédure nécessite une implémentation et des essais sur des comptes factices, couvrant l’activité concurrente, les avertissements non remis, les comptes sans profil et les photos. Ne pas programmer une suppression SQL brute d’`auth.users`.

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
