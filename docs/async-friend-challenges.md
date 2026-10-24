# Défis asynchrones

L'auteur peut lancer et terminer son quiz dès l'envoi, pendant que l'invitation reste en attente. Le destinataire garde son choix Accepter/Refuser et peut jouer plus tard. Les deux sessions portent sur les mêmes dix questions. Aucune présence simultanée n'est requise.

Le premier score reste enregistré et le bilan ne compte pas une victoire avant le second passage. Le calcul des scores reste côté serveur, à partir des réponses enregistrées. Lorsque le second score arrive, la transition vers completed produit exactement une notification personnalisée par participant, avec les deux scores et l'issue victoire/défaite/égalité. L'ancienne invitation est marquée lue. Les notifications restent stockées si le participant est déconnecté.

France conserve son moteur de sessions. Espagne et IFSI utilisent le moteur de questions de cursus. Un défi pending peut être joué uniquement par son auteur; le destinataire doit l'accepter. Les verrous de ligne sérialisent les transitions, le démarrage France réutilise la session existante et une nouvelle validation d'un résultat France ne renvoie pas de notification supplémentaire.

Les bannières affichent invitations et résultats; elles ouvrent directement l'onglet Défis. Les abonnements de la cloche et des pages utilisent des canaux distincts pour ne pas se désinscrire mutuellement.

## Validation

- `supabase/tests/async_friend_challenges.sql` : utilisateurs synthétiques, rôle authenticated réel, auteur jouant avant l'acceptation, refus des tiers et des résultats incomplets, conservation du premier score, résultat après le second, deux notifications seulement et réponses correctes masquées. France, Espagne et IFSI sont couverts. La transaction entière est annulée, y compris les comptes.
- `tests/e2e/duel-rivalries.spec.mjs` : bouton Jouer maintenant avant toute acceptation, moteur correct pour chaque cursus, résultat notifié avec les scores, accès direct et absence de débordement mobile.
- La recette connectée commence également le quiz de l'auteur avant de créer la session navigateur du destinataire.

## Migration et retour arrière

La migration de fonctions et de triggers est compatible avec l'interface précédente : aucun changement de colonne ni suppression de données. Elle est appliquée et testée en préproduction avant la production, puis l'interface passe par la CI et la recette connectée du commit main exact.

La migration locale reprend la version enregistrée par le service de migration de production, `20261024154528_async_friend_challenges`. Le backend de préproduction possède sa propre histoire de baseline et sa version de migration.

Un rollback du frontend peut conserver cette extension serveur. Si la logique serveur doit être restaurée explicitement, `database/rollback/async_friend_challenges.sql` restaure les cinq fonctions précédentes et retire les deux triggers. Les scores et réponses enregistrés sont conservés; les invitations en attente redeviennent soumises à l'acceptation avant jeu comme auparavant.
