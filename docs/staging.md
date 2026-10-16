# Environnement de test préparé

Après confirmation du propriétaire le 16 octobre 2026, le projet `leryko-v5-staging` est créé au tarif annoncé de 0 $ par mois en région `eu-west-1`, référence `cyzdivbdgpvhwpmikeqh`. Le schéma restreint est maintenant installé après autorisation explicite : 62 tables, 6 vues et 4 buckets. Les fixtures couvrent 3 cursus, 14 niveaux, 48 questions France et 240 questions du moteur de cursus. Aucune donnée de production n’a été copiée. Les comptes et écritures des tests SQL sont annulés : zéro utilisateur Auth, profil, tentative ou amitié après vérification.

Le frontend de production garde son URL et sa clé publique fixes. Pour une copie de test, définir explicitement `VITE_BACKEND_ENV=staging`, `VITE_SUPABASE_URL` et `VITE_SUPABASE_PUBLISHABLE_KEY` dans un fichier local privé ou les variables du futur hébergeur. Les configurations incomplètes, l'URL ou la clé de production, les clés serveur et les noms d'environnement inconnus sont refusés. Le build adapte la CSP au backend de test et désactive l'envoi vers le Sentry de production.

Pour lancer `npm run build`, ces variables doivent désigner un projet HTTPS distinct. Ne pas utiliser le nom de Worker `kineo` pour une publication de test : créer une configuration Wrangler distincte avec un autre nom et ne pas réutiliser le workflow de déploiement de production.

Avant de rendre cet environnement opérationnel :

1. Projet créé dans l’organisation `zepcjpwjeebxiysspyxc` après confirmation du coût annoncé. Tableau de bord : https://supabase.com/dashboard/project/cyzdivbdgpvhwpmikeqh. Le tarif annoncé ne constitue pas une garantie sur de futurs changements de forfait ou de consommation.
2. Schéma restreint installé depuis `scripts/staging/baseline.sql`, avec le trigger de reprise des sessions Auth ajouté ensuite. Le catalogue et le générateur incluent désormais ce trigger. L’historique ancien du dépôt reste réparti entre plusieurs dossiers ; un `db reset` complet n’est pas validé.
3. Désactiver les jobs cron, envois de mails et autres intégrations externes avant toute restauration. Utiliser exclusivement des comptes et données synthétiques pour les tests ordinaires.
4. Remplacer les références de projet dans les fonctions qui en contiennent (notamment préfixe d'avatar, workers et invocations cron). Ne pas recopier les secrets Vault ou les clés de production.
5. Configurer les URL Auth de test, le stockage privé et son contenu de fixture, puis exécuter les suites SQL et navigateur sur ce projet.
6. Tester la migration, la restauration et le retour arrière avant de changer la production.

Les tests unitaires vérifient l'absence de repli automatique de staging vers la production. Ils ne constituent pas une recette connectée sur le nouveau projet ni un exercice de restauration.

Les suites SQL `account_isolation`, `audit_regressions`, `daily_answer_visibility`, `account_retention` et `scripts/staging/test-three-curricula.sql` passent sur le projet de test. Le test de rétention initialise sa ligne de contrôle dans la transaction, elle aussi annulée. Voir `scripts/staging/README.md` pour les limites et les vérifications restant à faire dans le navigateur et sur le stockage réel.

## Worker isolé préparé

`wrangler.staging.jsonc` réserve le nom `leryko-v5-staging` et lit uniquement le dossier `staging-release`, distinct de `dist`. Ce dossier n’est pas fourni : une publication échoue tant qu’un build de test n’y a pas été préparé. Ne jamais y copier un candidat construit avec le backend de production.

Après création et validation du backend de test, construire avec les variables staging et les deux options V5 de `.env.example`. Vérifier que la CSP et les appels réseau ciblent uniquement le projet de test avant de copier le résultat dans `staging-release`. Utiliser ensuite explicitement `wrangler deploy --config wrangler.staging.jsonc`. Aucune publication n’est effectuée par la présence de ce fichier.

Pour l’exercice Cloudflare, relever les identifiants de version de deux publications successives sur ce Worker, restaurer explicitement la première, puis vérifier son `version.json`, ses assets et la mise à jour PWA. Consigner les identifiants et les résultats. Cet exercice reste à réaliser avec une session Cloudflare opérationnelle.
