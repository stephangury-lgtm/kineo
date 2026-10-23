# GURIKO — icônes d’installation (PR #40)

Les fichiers `guriko-180.png`, `guriko-192.png`, `guriko-512.png` et `guriko-1024.png` sont les fichiers PNG fournis par le propriétaire, copiés sans altération. Les planches approuvées restent les références de la future identité complète ; cette livraison ne prétend pas livrer toutes les poses ou tous les écrans.

Le manifeste conserve `id`, `start_url` et `scope` à `/` pour préserver l’identité de la PWA. iPhone utilise un nouveau chemin `guriko-180.png` ; l’ancien chemin Apple reçoit aussi le fichier approuvé. Les anciennes autres ressources restent présentes pour compatibilité. Les icônes GURIKO sont précachées hors connexion.

L’icône maskable est dérivée de l’original 1024 avec un fond opaque bleu #063B55 et l’illustration centrée en 288 × 288 dans 512 × 512 : ses quatre coins restent dans le cercle de sécurité central (rayon 204,8 pixels). Aucun élément n’est redessiné.

## Contrôles et publication

Le contrôle `check-guriko-release.mjs` vérifie signature PNG, dimensions, manifeste, balises iOS/favicon et précache. Le test navigateur `guriko-pwa.spec.mjs` décode réellement les PNG sous Chromium/Android et WebKit/iPhone et vérifie le cache PWA sous Chromium. Ces tests sont imposés avant publication et après publication ; un échec après publication déclenche le rollback existant.

Le workflow Cloudflare conserve la capture de l’UUID exact de version précédente, les sommes de contrôle de la livraison, la conservation de l’artefact 90 jours et la détection d’un déploiement concurrent. Le workflow manuel `rollback-cloudflare.yml` reste inchangé. Aucune migration Supabase. Fusion et production uniquement après réussite des contrôles du commit final et vérification de l’absence de publication Cloudflare concurrente.

Un appareil réel Android/iPhone n’est pas validé par une émulation Playwright. L’icône d’une installation iOS existante peut nécessiter sa réinstallation.

## Empreintes des sources approuvées

- `guriko-180.png` : SHA-256 `67f0e3213281bc96020911cd3d7836b9a78f82f96697cc1424a1898004beae54`
- `guriko-192.png` : SHA-256 `60b246df1625f18b47c8eb2dafb188a271eff21e85fdcfef05973771be6bacf5`
- `guriko-512.png` : SHA-256 `641b44a4474e94f91a03b7647799b8f74d846a6d0a370a0fc79e3d76c9fe0543`
- `guriko-1024.png` : SHA-256 `dd60eb38dba5e439a6819beaa5aecbd8698a21895e7b26643d909b075d6e8cdd`

## Finalisation du 23 octobre 2026

À la demande de Stéphan, la PR 40 est complétée : nom GURIKO dans la connexion, l’en-tête, le partage et les informations publiques ; image de mascotte approuvée fournie par le pack, affichée sur le rituel des trois cursus. L’en-tête associe l’icône d’origine à un nom d’application en texte, sans créer un nouveau dessin de logo. Les fichiers d’origine et leurs SHA-256 restent inchangés.

Une seule illustration approuvée est disponible : elle accompagne les messages localisés de progression, réussite et défi quotidien. Cette livraison ne prétend pas ajouter des poses différentes qui n’ont pas été fournies. Les états, les thèmes et la réduction des animations restent disponibles. Aucun changement des identifiants de cursus, de la base, des clés de session, des routes ni des URL de production.

Les six scénarios de marque (trois cursus × 320/390 px) vérifient l’image décodable, le nom visible, le retour accueil, le partage localisé, cinq onglets et l’absence de débordement. Ils sont ajoutés aux contrôles V5 et Android/iPhone. Le retour arrière conserve les ressources précédentes. La préparation d’identité n’est pas une validation juridique de disponibilité de marque ou de domaine.
