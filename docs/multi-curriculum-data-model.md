# Architecture multi-cursus

Objectif : faire évoluer Kineo vers une plateforme commune sans casser les données existantes.

## Principes

- Kineo France reste le parcours historique et la référence de compatibilité.
- Kineo España et IFSI utilisent le même moteur de quiz, de progression, de badges, de séries et de défis.
- Les contenus sont isolés par programme afin d'éviter tout mélange entre cursus.
- La migration de base de données sera additive dans un premier temps : aucune suppression ni renommage destructif des tables existantes.

## Hiérarchie cible

`program -> academic_level -> subject/UE -> chapter -> lesson -> question`

### program

- `kineo-fr`
- `kineo-es`
- `ifsi-fr`

### academic_level

- Kineo France : K1 à K4
- Kineo España : 1re à 4e année
- IFSI : S1 à S6

## Langues

Chaque contenu pourra porter :

- `content_language` : langue principale du contenu
- `translation_language` : langue secondaire optionnelle
- `translation_mode` : none / vocabulary / bilingual

Pour Kineo España, le contenu pourra être exploité en espagnol seul, français seul pour l'aide, ou mode bilingue FR/ES.

## Migration Supabase envisagée

Phase 1 (additive et réversible) :

1. créer `programs` ;
2. créer `academic_levels` ;
3. rattacher progressivement les années existantes de Kineo France à `kineo-fr` ;
4. ajouter `program_id` / `academic_level_id` aux nouvelles ressources ;
5. conserver les colonnes et relations historiques pendant la transition ;
6. ajouter les politiques RLS et les grants Data API explicitement.

Phase 2 : adapter les RPC et requêtes frontend pour filtrer systématiquement par programme.

Phase 3 : seulement après validation fonctionnelle, envisager la simplification des anciennes colonnes.

## Rollback

La branche `backup-kineo-stable-2026-10-03` reste le snapshot du code stable. Aucune migration destructrice ne doit être appliquée avant validation de la preview multi-cursus.
