# GURIKO — plan d'intégration (préproduction)

Statut initial du 22 octobre : identité provisoire. Mise à jour du 23 octobre : Stéphan demande l’intégration du nom et de la mascotte via la PR 40 ; les contrôles et le rollback restent obligatoires. Cette intégration ne vaut pas validation juridique des marques ou domaines.

## Principes
- Préserver les cursus `kineo-fr`, `kineo-es` et IFSI, les données Supabase, l'authentification et les contenus pédagogiques.
- Réutiliser les thèmes CSS existants `kine`, `fisio`, `ifsi` et les traductions françaises/espagnoles.
- Prévoir un composant `Mascot` réutilisable avec `state`, `program`, `size`, `decorative` et texte alternatif localisé.
- États : welcome, thinking, success, retry, progress, level-up, streak, badge, daily-challenge, friends, loading, empty, offline.
- Ne jamais afficher de message culpabilisant en cas d'erreur ; limiter les animations et respecter prefers-reduced-motion.
- Prévoir les ressources graphiques finales séparées, à fond transparent, optimisées mobile ; les planches de conception ne sont pas des assets prêts pour la production.

## Phases de livraison
1. Audit des composants, du manifeste PWA, des thèmes et des tests.
2. Ajouter le design system et des ressources provisoires isolées sur cette branche.
3. Intégrer par petits lots : accueil, quiz, progression, badges, amis, connexion.
4. Vérifier build, tests unitaires, Playwright, contraste et Android/iOS.
5. Créer une PR non fusionnée, revue et prévisualisation Cloudflare ; production seulement après validation.

## Critères d'acceptation
- Aucun changement du schéma Supabase ni des données des étudiants.
- Aucun remplacement global du nom Leryko/Kineo avant validation juridique.
- Les trois cursus restent accessibles et les interactions tactiles fonctionnent.
- Possibilité de désactiver les nouvelles mascottes sans migration de données.
