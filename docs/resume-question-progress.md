# Progression lors de la reprise d’une séance

Après la première réponse d’une séance de trois questions, `get_quiz_questions_v4` renvoyait les questions restantes avec les numéros 1 et 2. L’interface pouvait donc afficher « Question 1 sur 2 » au lieu de « Question 2 sur 3 ».

Le filtre des questions déjà traitées s’appliquait avant `row_number()`. La migration classe désormais les questions de la séance avant ce filtre, puis ne renvoie que celles encore disponibles et non traitées. Les identifiants et réponses enregistrées sont conservés. Le contrôle du propriétaire, le refus des séances abandonnées et le masquage des corrections restent en place ; aucun droit n’est ajouté.

Référence : [PostgreSQL — fonctions fenêtre et filtrage](https://www.postgresql.org/docs/current/tutorial-window.html).

## Vérification

Dans une connexion PostgreSQL de staging déjà configurée, exécuter :

```sh
psql -X -v ON_ERROR_STOP=1 -f tests/sql/resume-question-order.sql
```

Le test ouvre une transaction, applique la migration, crée uniquement un compte et une séance fictifs, vérifie les rangs 2/3 puis 3/3, le compteur de réponses, le masquage des corrections et les refus d’accès. Il annule ensuite la transaction. Ne pas utiliser un compte réel comme fixture.

Une recette équivalente a été exécutée sur staging avec cinq contrôles réussis ; le rétablissement explicite de la fonction précédente a également été testé. La vérification après transaction confirme zéro compte et zéro séance synthétiques résiduels. Trois scénarios navigateur vérifient l’affichage et l’absence de nouvelle soumission de la question déjà traitée, avec une API fictive.

## Application et retour arrière

La migration refuse de remplacer une définition de fonction différente de celle auditée : en cas de refus, examiner la modification concurrente. Ne pas supprimer la garde pour forcer l’application.

La publication du code ne suffit pas à appliquer cette migration SQL. Son application à la base cible doit être suivie du test de reprise et du contrôle des accès sur cette base. La préparation et les tests décrits ici n’attestent pas d’une application en production.

Pour annuler cette seule modification, `database/rollback/stable_resume_question_progress.sql` restaure la définition précédente avec une garde sur la nouvelle version. Ce retour arrière ne supprime ni séance ni réponse.
