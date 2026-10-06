# Audit de régression des retours Kineo — 2026-10-06

## État de la file de retours
- 49 retours enregistrés.
- 49 au statut `resolved`.
- 0 retour ouvert / nouveau / en attente au moment du contrôle.

## Retours récents revalidés dans le code

### Accueil
- Carte blanche « Parcours » masquée dans la grille rapide.
- Grille des raccourcis en 2 colonnes pour limiter le scroll.
- Hero compacté ; l’illustration cerveau n’est plus affichée.
- CTA de session en cours alignés sur deux colonnes et de même hauteur.
- Carte « moteur pédagogique » absente de l’accueil.

### Profil
- Changement de niveau disponible selon le cursus.
- Bouton de suppression de photo doté d’un style d’action destructive dédié.

### Statistiques
- Indicateurs principaux regroupés dans le hero de statistiques.
- Présentation densifiée pour réduire le scroll.

### Bibliothèque
- Page simplifiée autour de deux blocs principaux : favoris et notes.
- Suppression de l’empilement de cartes peu informatives.

### Administration visuelle
- Les visuels en quarantaine restent accessibles au contrôle admin.
- Recalibrage des cibles par clic disponible.
- Checklist anatomie / mobile / cible / source disponible avant validation.

### Multi-cursus
- Routage séparé pour Kineo FR, Kineo ES et IFSI.
- Les pages de cours utilisent le contrôle d’accès du cursus actif.

## Conclusion
Aucune régression bloquante retrouvée sur les retours récents audités. La file utilisateur est vide à l’issue de ce contrôle.
