# Kineo — audit de durcissement bêta

Date: 2026-10-02

## Sessions et gamification

- 2 sessions terminées auditées sans divergence entre question_count, attempts et correct_count.
- 7 sessions encore ouvertes, toutes créées le 2026-10-02 : aucune fermeture automatique appliquée.
- Aucun XP négatif détecté.
- Aucun attempt supérieur au nombre de questions assignées.
- Aucun streak négatif, aucune date d’activité future, current_streak <= longest_streak.

## Sécurité Supabase

- RLS actif sur les 32 tables publiques.
- Les politiques sensibles inspectées limitent les lectures utilisateur à auth.uid() pour profils, sessions, tentatives, notifications et streaks.
- Les questions/options publiées sont lisibles par les utilisateurs authentifiés.
- Les fonctions RPC modernes utilisées par le frontend sont en SECURITY DEFINER avec search_path verrouillé à vide.
- Plusieurs fonctions historiques restent avec search_path=public ; elles sont conservées pour compatibilité tant qu’un retrait formel n’est pas testé.

## Anatomie

- 64 fiches anatomiques réalistes publiées en WebP.
- 0 ancien SVG publié.
- Les 64 anciens hotspots/labelings SVG ont été archivés et retirés de la file review.
- Les fichiers SVG historiques restent dans public/quiz-assets afin de préserver la consultation des contenus archivés ; ils ne sont plus utilisés par le contenu publié.

## Parcours

- K1 legacy désactivé et sans contenu publié.
- K2 contient actuellement le corpus validé.
- K3 et K4 ont leur structure mais pas de contenu publié.
- K5 est actif mais vide.
- Aucun contenu K3-K5 n’est créé sans source validée.

## CI

- Workflow GitHub Actions ajouté : npm ci puis npm run build sur push main et pull requests vers main.

## Règles de bêta

1. Ne jamais réintroduire les anciens SVG dans le contenu publié.
2. Ne pas fermer automatiquement une session utilisateur récente.
3. Toute nouvelle fonctionnalité doit passer le build CI avant mise en production.
4. Ne pas alimenter K3-K5 sans documents pédagogiques validés.
5. Préserver RLS et l’isolation auth.uid() sur toutes les données utilisateur.
