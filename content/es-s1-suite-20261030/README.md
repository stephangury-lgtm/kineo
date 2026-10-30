# Espagne S1 · deuxième lot · 2026-10-30

## Résultat
Six chapitres de cours avec 10 exercices chacun, plus une fiche de méthode :
- Homéostasie : capteur, centre, effecteur et rétroaction.
- Anatomie cardiaque : circulation, cavités et valves.
- Appareil respiratoire : conduction, alvéoles et cellules.
- Sang : composants, protéines et hématocrite.
- CIF : fonctions, structures, activité, participation et contexte.
- Communication : compréhension, reformulation et décision partagée.
- Méthode : rappel actif, pratique répartie et analyse des erreurs.

60 questions originales : 45 QCM et 15 cas d'application. Quatre options, une correcte, explication et source par question. Deux anciennes questions mixtes FR/ES réécrites en castillan. Treize fiches existantes remises en forme : normalisation des retours littéraux et séparation des titres, sans ajout d'affirmations médicales.

## Sources et limites
Plans UVic : Anatomía I (4402), Fisiología I (4405), Fundamentos (4412), Psicología (4409).
Contenus spécifiques : OpenStax Anatomy and Physiology 2e, OpenStax Psychology 2e, OMS CIF Checklist, manuel pratique OMS (projet 2013), NICE NG197.
NICE est une référence britannique de communication, pas du droit espagnol. Le guide de révision donne des exemples d'organisation et ne configure aucune relance automatique.
Ces compléments ne couvrent pas tout le semestre et ne sont pas des annales. Révision enseignante externe encore à effectuer. Pas d'actualisation des PDF existants dans ce lot.

## Validation effectuée
- Zéro doublon textuel parmi les ajouts et avec les questions existantes.
- Quatre options distinctes et une réponse correcte par question.
- Publication complète dans une transaction de test puis annulation.
- Lecture des 60 questions et des 7 fiches sous rôle authenticated, affectation Espagne existante.
- Absence d'indicateur correct et de correction dans la réponse initiale de la RPC.
- Retour arrière essayé dans la même transaction : restauration des 13 contenus et des 2 questions, dépublication des 60 ajouts.
- Publication effective après sauvegarde Git ; contrôle quantitatif après publication.
- Pas de modification du frontend, du schéma, des comptes ou des droits. Aucun progrès étudiant créé par ces tests.
- Vérification de présentation fondée sur le parseur ReadableCourseContent existant ; pas de recette visuelle navigateur dans cette session.

## Retour arrière
Exécuter rollback.sql pour ce deuxième lot avant tout rollback du premier lot.
Le rollback désactive les nouveaux chapitres et dépublie les fiches et questions ajoutées ; il préserve les identifiants et références d'historique.
Les versions précédentes sont dans bundle.json. La restauration conditionnelle évite d'écraser les contenus modifiés depuis cette publication ; examiner les conflits éventuels.
