# Négation et nombres dans les réponses libres

La comparaison permissive pouvait considérer `pas externe` comme équivalent à `externe`, par inclusion du texte attendu. Elle pouvait aussi accepter `20 secondes maximum` pour `15 secondes maximum`, car le recouvrement de mots ignorait les petits nombres. Ces exemples ont été reproduits sur staging sans enregistrer de réponses d’apprenants.

La migration conserve les normalisations existantes, mais vérifie la présence de marqueurs explicites de négation et la séquence des nombres avant toute comparaison permissive. Les nombres seuls sont normalisés pour les décimales avec virgule ou point, les zéros non significatifs et les signes. Les unités de temps déjà reconnues restent acceptées.

Lorsqu’une négation ou un nombre est présent, une simple inclusion ou un recouvrement de mots ne suffit plus : la formulation doit correspondre au texte normalisé ou à une variante explicitement enregistrée pour la question. Les autres réponses positives sans nombre conservent le comportement antérieur.

## Limites à conserver dans la revue pédagogique

Ce filtre est conservateur. Il peut refuser une paraphrase numérique ou négative valable qui n’est pas encore référencée : examiner alors la question et ajouter une variante sourcée, avec tests positifs et négatifs. Ce n’est pas une analyse sémantique générale, ni une validation clinique indépendante du correcteur. Les antonymes, unités complexes et raisonnements longs nécessitent encore une revue propre à la question.

## Vérification et application

`tests/sql/free-answer-polarity-and-numbers.sql` couvre 26 comparaisons : négation ajoutée ou retirée en français/espagnol/anglais, formulations négatives contradictoires, nombres et signes différents, unités incompatibles, normalisations valables et réordonnancement positif.

```sh
psql -X -v ON_ERROR_STOP=1 -f tests/sql/free-answer-polarity-and-numbers.sql
```

La transaction applique la migration dans l’environnement isolé et s’annule après les assertions. Une recette équivalente a été exécutée sur staging ; la restauration explicite de la fonction précédente est vérifiée. Six soumissions supplémentaires sous rôle apprenant ont testé la variante `externe` du carré fémoral, dont le refus de `pas externe`, avec corrections cachées puis affichées et retour arrière.

La migration et le rollback refusent d’écraser une autre définition de fonction. Ils ne changent aucun droit et ne suppriment aucune tentative. Ces tests ne signifient pas que la migration est appliquée en production. Le lot pédagogique lié reste suspendu tant que cette protection n’est pas active et vérifiée sur la base cible.
