# Rituel quotidien mobile — préversion

## Comportement

L’accueil V5 expose une action principale et deux raccourcis : cours et révision libre. La barre conserve cinq accès sur une seule ligne : Parcours, Amis, Ma séance, Progrès, Profil. Le bouton central ouvre ou reprend une séance ; le logo ramène à l’accueil. Les libellés sont adaptés au cursus Espagne. L’invitation aux rappels reste disponible dans le profil et ne précède plus la séance sur l’accueil V5. La flamme et les badges proviennent des services existants ; aucune valeur fictive n’est introduite.

France conserve les séances et le défi quotidien côté serveur. Une séance déjà montée est reprise avec son URL exacte afin de conserver un choix non validé ou une correction déjà reçue. Sans séance en mémoire, le lecteur vérifie la séance serveur avant de proposer un nouveau défi ; un échec de lecture ne crée pas de séance supplémentaire.

Espagne et IFSI utilisent le pool cumulatif validé existant, avec au maximum dix questions et un démarrage direct. La séance reste montée pendant les détours vers les cours, les PDF ou les autres onglets. Le bilan et l’état « objectif accompli » n’apparaissent qu’après validation de la série. Les réponses sont toujours validées par le service existant.

## Limites explicites

- Pour Espagne et IFSI, la reprise est en mémoire dans l’onglet : une actualisation, une fermeture, une déconnexion, un changement de cursus ou d’interface l’effacent. Les réponses déjà envoyées restent gérées par le serveur. Cette modification ne crée pas de défi quotidien persistant, de compteur de défis ou de reprise multi-appareil pour ces cursus.
- L’indication 8–10 minutes est une estimation ; aucun arrêt brutal ni garantie de durée maximale n’est imposé. Les séries comprennent au maximum dix questions, mais leur difficulté et le rythme de lecture font varier le temps réel.
- Pas de modification des contenus, PDF, comptes, règles RLS, fonctions SQL, migrations ou mécanismes de récompense.

## Réversibilité et déploiement

Les changements visuels et la nouvelle navigation sont conditionnés à V5. Le sélecteur d’interface existant reste disponible. La compilation sans aperçu V5 conserve le parcours historique. Aucun déploiement en production n’est déclenché par la branche de travail ; la fusion reste soumise aux contrôles existants. L’acceptation connectée doit viser le commit final avant toute publication V5, conformément au workflow actuel.

## Recette

Tests de régression : échec de reprise, priorité de séance active, conservation d’une réponse/correction, fin de série après dix validations, absence de création à l’ouverture des cours, badges, communauté, partage, refus administrateur étudiant, retour à l’ancienne interface, rendu 320/390/1024 pixels et trois moteurs navigateur.

Le déploiement distant de cette préversion n’a pas été effectué à ce stade. L’accès CLI Cloudflare local n’est pas authentifié ; ne pas contourner les contrôles de publication existants.
