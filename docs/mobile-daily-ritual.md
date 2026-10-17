# Rituel quotidien mobile — préversion

## Comportement

L’accueil V5 expose une action principale et deux raccourcis : cours et révision libre. La barre conserve cinq accès sur une seule ligne : Parcours, Amis, Ma séance, Progrès, Profil. Le bouton central ouvre ou reprend une séance ; le logo ramène à l’accueil. Les libellés sont adaptés au cursus Espagne. L’invitation aux rappels reste disponible dans le profil et ne précède plus la séance sur l’accueil V5. La flamme et les badges proviennent des services existants ; aucune valeur fictive n’est introduite.

France conserve les séances et le défi quotidien côté serveur. Une séance déjà montée est reprise avec son URL exacte afin de conserver un choix non validé ou une correction déjà reçue. Sans séance en mémoire, le lecteur vérifie la séance serveur avant de proposer un nouveau défi ; un échec de lecture ne crée pas de séance supplémentaire.

Espagne et IFSI utilisent le pool cumulatif validé existant, avec au maximum dix questions et un démarrage direct. La séance reste montée pendant les détours vers les cours, les PDF ou les autres onglets. Un point de reprise dans sessionStorage conserve aussi la séquence, le choix et la correction reçue après actualisation. La clé sépare compte, cursus, niveau, référentiel et journée locale. Avant de reprendre, les questions sont relues dans le pool autorisé courant. Aucun point de reprise ne soumet une réponse ni n’attribue des points. La déconnexion efface ces points de reprise. Le bilan et l’état « objectif accompli » n’apparaissent qu’après validation de la série. Les réponses sont toujours validées par le service existant.

## Limites explicites

- Pour Espagne et IFSI, la reprise après actualisation fonctionne dans le même onglet pendant la journée locale, si sessionStorage est disponible. Fermer l’onglet ou se déconnecter efface cette reprise. La reprise ne se synchronise pas entre appareils. Les réponses déjà envoyées restent gérées par le serveur. Un contenu retiré des accès provoque une erreur explicite avec possibilité de recommencer ; il n’est pas affiché depuis le stockage local. Les données locales ne constituent pas une preuve de progression serveur.
- L’indication 8–10 minutes est une estimation ; aucun arrêt brutal ni garantie de durée maximale n’est imposé. Les séries comprennent au maximum dix questions, mais leur difficulté et le rythme de lecture font varier le temps réel.
- Pas de modification des contenus, PDF, comptes, règles RLS, fonctions SQL, migrations ou mécanismes de récompense.

## Réversibilité et déploiement

Les changements visuels et la nouvelle navigation sont conditionnés à V5. Le sélecteur d’interface existant reste disponible. La compilation sans aperçu V5 conserve le parcours historique. Aucun déploiement en production n’est déclenché par la branche de travail ; la fusion reste soumise aux contrôles existants. L’acceptation connectée doit viser le commit final avant toute publication V5, conformément au workflow actuel.

## Recette

Tests de régression : échec de reprise, priorité de séance active, conservation d’une réponse/correction, fin de série après dix validations, absence de création à l’ouverture des cours, badges, communauté, partage, refus administrateur étudiant, retour à l’ancienne interface, rendu 320/390/1024 pixels et trois moteurs navigateur.

Le déploiement distant de cette préversion n’a pas été effectué à ce stade. L’accès CLI Cloudflare local n’est pas authentifié ; ne pas contourner les contrôles de publication existants.

## Résultats locaux du 17 octobre 2026

- 26 tests unitaires réussis et invariants de source validés.
- 60 scénarios V5 validés sur Chromium, WebKit et Firefox : 54 dans la passe générale, puis les neuf scénarios de séance (dont six corrigés dans le test) dans une passe dédiée sans échec ni reprise automatique. Les attentes synchronisent chaque nouvelle question ; le scénario de dix réponses dispose de 90 secondes pour couvrir toute la série sur les moteurs mobiles.
- Vérifications visuelles sur les trois cursus, largeurs 320, 390 et 1024 pixels : cinq accès sur une ligne, bouton principal visible sans défilement, pas de débordement horizontal.
- Compilations V5 et historique réussies. Les navigateurs utilisent des données fictives et des API interceptées : ces résultats ne remplacent pas la recette connectée sur staging avant publication.

