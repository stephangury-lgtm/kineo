# GURIKO — références graphiques approuvées (22 octobre 2026)

## Sources maîtresses
Deux planches fournies et explicitement validées par le propriétaire du projet dans la conversation Kineo v2 :
- `1000028107.png` : système d'identité, icônes, parcours, mascotte et déclinaisons par cursus.
- `1000028106.png` : logo, icônes, palette, écrans, poses et expressions.

Ces fichiers doivent être récupérés comme **assets binaires d'origine** avant toute intégration définitive ; les descriptions ci-dessous ne les remplacent pas.

## Invariants non négociables
- Mascotte **unique** : chevelure en feuilles turquoise volumineuses, visage crème, grands yeux turquoise/noirs, joues roses, tenue menthe avec feuille, sac bleu marine, touches corail. Silhouette, proportions et visage cohérents entre toutes les poses.
- Logo **GURIKO** : lettres arrondies bleu profond, accents corail ; ne pas utiliser d'autres logos inventés.
- Palette : bleu profond, turquoise, menthe, corail, pêche, gris clair.
- Écrans : fonds clairs, cartes arrondies, boutons turquoise, navigation basse, hiérarchie accessible.
- Cursus : Kiné France turquoise, Kiné Espagne bleu, IFSI France violet ; **la mascotte ne change pas** selon le cursus.
- Écrans de référence : splash, connexion, sélection cursus, accueil, parcours, quiz anatomie, bonne réponse, statistiques, badges, profil.
- États : accueil, motivation, réflexion, victoire, erreur bienveillante, progression, niveau supérieur, série/flammes, badge, défi du jour, amis, chargement, hors connexion.

## Garde-fous d'implémentation
1. Ne pas générer une nouvelle interprétation de la mascotte ou du logo pour les écrans ; réutiliser des assets dérivés des planches approuvées.
2. Ne pas considérer des découpes approximatives de planches comme des fichiers transparents prêts pour production : contrôler les fonds, contours, résolution et marges de sécurité.
3. Vérifier visuellement icônes Android (dont maskable), iOS, PWA et responsive avant fusion.
4. Maintenir la branche `feature/guriko-branding` et la PR #40 en brouillon tant que les assets définitifs, les tests et les vérifications de marque ne sont pas terminés.
5. Ne pas modifier la base Supabase ni la production lors de ce travail graphique.
