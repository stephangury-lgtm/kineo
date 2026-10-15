# Environnement de test préparé

Décision du propriétaire, 15 octobre 2026 : préparer les fichiers seulement. Aucun projet ni abonnement Supabase supplémentaire créé, aucune copie de données de production effectuée.

Le frontend de production garde son URL et sa clé publique fixes. Pour une copie de test, définir explicitement `VITE_BACKEND_ENV=staging`, `VITE_SUPABASE_URL` et `VITE_SUPABASE_PUBLISHABLE_KEY` dans un fichier local privé ou les variables du futur hébergeur. Les configurations incomplètes, l'URL ou la clé de production, les clés serveur et les noms d'environnement inconnus sont refusés. Le build adapte la CSP au backend de test et désactive l'envoi vers le Sentry de production.

Pour lancer `npm run build`, ces variables doivent désigner un projet HTTPS distinct. Ne pas utiliser le nom de Worker `kineo` pour une publication de test : créer une configuration Wrangler distincte avec un autre nom et ne pas réutiliser le workflow de déploiement de production.

Avant de rendre cet environnement opérationnel :

1. Choisir l'organisation et confirmer le coût Supabase avant création, ou installer un environnement local compatible.
2. Charger un schéma de référence cohérent puis les migrations. L'historique comporte plusieurs dossiers (`database/migrations` et `supabase/migrations`) : ne pas prétendre qu'un simple `db reset` est déjà validé.
3. Désactiver les jobs cron, envois de mails et autres intégrations externes avant toute restauration. Utiliser exclusivement des comptes et données synthétiques pour les tests ordinaires.
4. Remplacer les références de projet dans les fonctions qui en contiennent (notamment préfixe d'avatar, workers et invocations cron). Ne pas recopier les secrets Vault ou les clés de production.
5. Configurer les URL Auth de test, le stockage privé et son contenu de fixture, puis exécuter les suites SQL et navigateur sur ce projet.
6. Tester la migration, la restauration et le retour arrière avant de changer la production.

Les tests unitaires vérifient l'absence de repli automatique de staging vers la production. Ils ne constituent pas un environnement de test provisionné ni un exercice de restauration.
