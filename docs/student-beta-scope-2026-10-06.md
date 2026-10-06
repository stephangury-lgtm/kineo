# Kineo v2 — périmètre bêta étudiant — 2026-10-06

## Périmètre pédagogique prêt pour bêta

### Kineo France
- K2 : prêt pour bêta
- K3 : prêt pour bêta
- K4 : prêt pour bêta
- K5 : hors périmètre — contenus encore en préparation

### Kineo Espagne
- ES1 : prêt pour bêta
- ES2–ES4 : hors périmètre — contenus non encore publiés

### IFSI France
- Référentiel 2026 : S1 à S6 prêts pour bêta
- Référentiel 2009 : hors périmètre prioritaire ; contenu historique conservé mais non enrichi artificiellement

## Garde-fous actifs
- Questions publiées sourcées et contrôlées.
- IFSI 2026 : 48/48 fiches publiées sous statut `source_validated`.
- Challenges quotidiens et duels multi-cursus filtrés par programme + niveau + version de référentiel.
- Tous les semestres IFSI 2026 disposent d'au moins 10 QCM validés pour les duels.
- Aucun retour utilisateur ouvert.
- Aucun RPC `SECURITY DEFINER` authentifié exposé à `anon`.
- Aucune réponse PostgREST 500/502/503/504 détectée lors de l'audit des dernières 24 h.

## Anatomie visuelle
Les 64 exercices anatomiques interactifs restent volontairement en quarantaine :
- 56 hotspots + 8 exercices de placement ;
- 64/64 ont une image et une source page + extrait ;
- 0 visuel archivé n'est publié ;
- 0 coordonnée de cible hors image ;
- 2 exercices quadriceps sont explicitement bloqués car les fichiers vaste médial / vaste latéral sont identiques ;
- la validation réelle anatomie + cible + tactile mobile reste requise avant réactivation.

La bêta étudiant peut donc démarrer sans le mode anatomie visuelle.

## Checklist d'acceptation appareil réel
À exécuter au minimum sur un iPhone récent et un Android récent, en portrait :

1. Connexion
   - connexion correcte ;
   - mauvais mot de passe => message explicite ;
   - afficher/masquer le mot de passe ;
   - mot de passe oublié ;
   - nouveau mot de passe >= 8 caractères.
2. Profil
   - premier paramétrage ;
   - niveau/semestre correct ;
   - changement de cursus autorisé uniquement ;
   - avatar et déconnexion.
3. Révision
   - QCM ;
   - texte à trous ;
   - matching ;
   - cas clinique ;
   - correction + XP ;
   - progression enregistrée après rechargement.
4. Sessions
   - démarrer une session ;
   - quitter l'app ;
   - reprendre la session ;
   - abandonner la session ;
   - historique et statistiques cohérents.
5. Challenge du jour
   - uniquement questions du niveau et du référentiel attribués ;
   - 5 questions ;
   - XP et série mis à jour.
6. Amis / duels
   - invitation ;
   - duel disponible uniquement même cursus + même niveau + même version ;
   - 10 questions ;
   - scores et résultat enregistrés.
7. Mobile/PWA
   - aucun débordement horizontal ;
   - zones tactiles >= 44 px ;
   - clavier ne masque pas les actions ;
   - bottom-nav accessible ;
   - installation PWA ;
   - fermeture/réouverture ;
   - perte puis retour réseau sans perte de session.
8. Feedback
   - envoyer un retour bug/contenu/suggestion ;
   - vérifier son apparition dans l'admin.

## Critères de feu vert bêta
- CI principal vert ;
- 0 erreur 500 sur les parcours de test ;
- 0 blocage connexion/révision/reprise ;
- 0 question hors niveau/référentiel ;
- 0 débordement mobile bloquant ;
- anatomie visuelle reste masquée tant que la QA tactile n'est pas terminée.

## Déploiement
La production cible reste Cloudflare Workers. Le contrôle de l'URL de production doit être fait depuis un réseau/appareil réel avant l'ouverture de la bêta ; l'environnement automatisé utilisé lors de cet audit ne résout pas actuellement le domaine workers.dev.
