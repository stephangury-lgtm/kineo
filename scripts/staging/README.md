# Schéma de recette isolée

Cible exclusive : `leryko-v5-staging`, référence `cyzdivbdgpvhwpmikeqh`.
Le projet est créé et le schéma restreint est installé. Seules des fixtures synthétiques sont conservées ; les comptes et écritures des tests transactionnels sont annulés.

## Fichiers de revue

- `catalog.json` : structure relevée en lecture seule, définitions des fonctions et droits ; aucune ligne métier, compte, secret Vault ou objet Storage.
- `export-catalog.sql` : requête de structure, sans export de données. Les permissions de colonnes et les paramètres des buckets ont été relevés séparément dans le catalogue.
- `prepare-schema.mjs` : génération de `baseline.sql` pour la cible fixe.
- `check-schema.mjs` : contrôle statique des références de projet, droits anonymes, liste des droits d’écriture et neutralisation des envois externes.
- `validation.json` : empreinte du fichier SQL et résultats statiques. Aucun test SQL ou navigateur connecté n’est présenté comme réussi.

Relancer `node scripts/staging/prepare-schema.mjs`, puis `node scripts/staging/check-schema.mjs` pour reproduire les fichiers. Ce n’est pas une commande de publication ou d’installation.

## Portée proposée

62 tables dans les schémas applicatifs, 6 vues, 161 fonctions, 71 politiques RLS et 27 triggers applicatifs, dont ceux d’Auth et Storage. Les tables publiques ont RLS activé. Les droits anonymes sur tables et fonctions ne sont pas repris. Les écritures directes du rôle connecté sont limitées à 13 droits existants sur notes, amitiés, défis, notifications, affectations de cursus, favoris et préférences de classement. Les mises à jour de profil restent limitées aux colonnes prévues. Les scénarios d’isolation et des trois cursus ont été exercés avec le rôle PostgreSQL `authenticated` ; cela ne valide pas encore l’authentification HTTP du navigateur.

Les références au projet source sont remplacées par la cible. `retention.invoke_worker` et `queue_inactivity_reminders_v1` lèvent une erreur explicite en staging. Aucun job cron ni secret n’est copié. Les buckets sont créés vides ; seul le bucket d’avatars conserve sa visibilité publique prévue par l’application. Les documents restent privés. Les fonctions internes de santé qui consultent cron ne sont pas opérationnelles sans configuration dédiée ; elles ne sont pas lancées par ce fichier.

Le fichier est une reconstruction depuis le catalogue, pas un export pg_dump complet ni une sauvegarde restaurable. Les réglages Auth, Data API, SMTP, fonctions Edge et paramètres du serveur ne sont pas copiés. Les URL Auth et le contrôle Data API prérequête restent à configurer et à vérifier séparément.

## Installation et tests effectués

Après les refus initiaux de la revue automatique, le propriétaire a explicitement autorisé l’installation du schéma restreint et les tests dans staging. La migration a réussi. Un trigger applicatif sur `auth.sessions`, absent du premier relevé, a été ajouté par une seconde migration et intégré au générateur. Les fixtures sont générées localement, sans UUID imposé ni extraction de contenu de production.

Les cinq suites SQL exécutées avec succès sont `account_isolation`, `audit_regressions`, `daily_answer_visibility`, `account_retention` et `test-three-curricula.sql`. Le test de rétention ajoute temporairement `insert into retention.worker(id) values(true) on conflict(id) do nothing` après `begin`, puis annule toute la transaction. La dernière suite couvre les invitations et la création de défis dans les trois cursus, l’acceptation et le refus d’accès aux tiers, un quiz France complet avec XP et série, les réponses Espagne/IFSI sans double attribution XP, les notes, favoris et résumés de progression. Elle ne termine pas un duel complet entre deux participants.

Les contrôles après tests confirment zéro utilisateur Auth, profil, amitié, tentative, notice de rétention ou objet Storage. Le schéma contient zéro table publique sans RLS, zéro droit anonyme sur les tables publiques et zéro fonction publique SECURITY DEFINER exécutable par anon.

L’analyse Supabase conserve 80 avertissements sur les fonctions SECURITY DEFINER exécutables par les utilisateurs connectés : ces RPC sont prévues par le moteur existant et ne doivent pas être annoncées comme toutes auditées individuellement. [Explication du contrôle](https://supabase.com/docs/guides/database/database-linter?lint=0029_authenticated_security_definer_function_executable). Dix informations « RLS sans politique » concernent des tables internes ou accessibles par RPC privilégiée ; aucune politique permissive n’est ajoutée pour faire disparaître ces informations.

Restent à vérifier : connexion HTTP et session réelle, documents PDF et objets Storage, fin de duel complet, réglages Auth/Data API, navigation connectée sur les trois cursus, publication Cloudflare et restauration réelle. Certains tests existants supposent le contenu de production (par exemple 24 PDF) et nécessitent une adaptation aux fixtures. Les comptes de test ne doivent pas recevoir d’e-mails réels. Le fichier `validation.json` reste volontairement un rapport statique ; il ne remplace pas ce compte rendu des tests SQL.
