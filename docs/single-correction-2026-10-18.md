# Une seule réponse attendue dans la correction

Retour concerné : `f1abb191-6a99-4b13-b974-b71bed3d6467` (« réponse en double »), page `/quiz?mode=daily`.

Une réponse rédigée incorrecte affichait la réponse attendue sous le champ puis dans le panneau de résultat. Pour un QCM, la présence simultanée de `correct_answer` et `correct_option_ids` pouvait aussi produire deux lignes. Le rendu utilise maintenant un seul emplacement dans le panneau, avec priorité au libellé des options identifiées ; la réponse textuelle sert de repli. Le mode examen continue à cacher toute correction avant la fin. Le calcul serveur, les réponses acceptées et les tentatives ne changent pas.

Vérifications locales : compilation TypeScript/Vite, 28 tests unitaires et invariants source réussis ; neuf tests navigateur sur l’interface historique puis 24 sur la V5, tous réussis. Les 24 comprennent les neuf cas de correction et quinze régressions existantes sur badges, défilement, amis et bandeau quotidien, avec les trois cursus là où ces cas le prévoient. Navigateurs : Chromium, WebKit et Firefox ; API entièrement simulées et aucun compte réel créé. Les vérifications de correction sont ajoutées aux contrôles CI et aux deux candidats réversibles. Les premiers essais du scénario examen visaient un mauvais intitulé de bouton dans le test ; corrigé pour vérifier « Terminer l’examen », puis suites relancées avec succès.

Le signalement ne doit être clôturé qu’après publication et vérification du correctif. Aucun test de ce lot ne prétend valider les visuels anatomiques ou la qualité clinique des questions. État des autres points de lancement : `launch-status-2026-10-18.md`.
