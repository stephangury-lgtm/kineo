# Kineo v2 — Beta readiness

Date: 2026-10-03
Version: KINEO-V2-2026.10.03-I

## Validé côté code et backend

- Authentification Supabase et récupération de mot de passe
- Profil étudiant K2 à K5
- Garde-fous en cas de profil indisponible : réessayer ou se déconnecter
- Dashboard et parcours K2
- Révisions intelligentes
- Révisions par matière
- Anatomie visuelle : 64 fiches WebP publiées, 16 par région
- Mes erreurs / points faibles
- Examen blanc
- Sessions : lancement, reprise, fin et historique
- XP, niveaux, badges et flammes
- Challenge du jour
- Amis, invitations, défis et classement
- Notifications
- Bibliothèque, favoris et notes
- RLS activé sur les 32 tables publiques
- Anciennes questions SVG retirées de la file de validation et archivées
- CI GitHub automatique sur push et pull request
- Build TypeScript + Vite validé par CI
- Service worker et PWA configurés

## Contrôles backend effectués

- aucune session terminée avec nombre de réponses incohérent
- aucun XP négatif
- aucune tentative supérieure au nombre de questions assignées
- aucune série négative ou incohérente
- aucune erreur PostgreSQL récente observée lors du contrôle
- 64/64 fiches anatomiques publiées avec source et WebP

## À valider sur appareils réels

- installation PWA Android
- installation PWA iPhone/iOS
- rendu des 64 visuels sur petit écran
- clics et zones interactives au doigt
- navigation avec clavier virtuel ouvert
- comportement hors ligne puis reconnexion
- réception et ouverture des e-mails de confirmation/reset selon le client mail

## Avant ouverture publique large

- domaine personnalisé éventuel
- SMTP personnalisé pour les e-mails Kineo
- mentions légales
- politique de confidentialité
- procédure de suppression de compte et des données personnelles
- contenu validé K3, K4 et K5 avant publication de ces années

## Règle de publication contenu

Ne jamais remplir artificiellement une année avec du contenu d’une autre année. Un contenu pédagogique n’est publié que s’il est sourcé et validé.
