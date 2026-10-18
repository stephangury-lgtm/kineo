# Lecteur de cours PDF — vérification

Le rendu natif d'un PDF dans une iframe n'est pas fiable sur tous les navigateurs mobiles. Le lecteur rend une page à la fois dans l'application avec PDF.js 6.4.299, navigation, agrandissement et texte accessible lorsqu'il existe dans le document. Le lien signé d'ouverture externe et l'actualisation d'accès restent disponibles.

Le moteur et ses polices, tables de caractères et décodeurs sont servis par l'application, sans CDN. La politique CSP autorise uniquement le worker de même origine. Les permissions Storage et la durée des liens signés (900 secondes) ne changent pas. Le moteur n'est chargé que sur la route du document ; le budget de l'entrée de l'application reste à 100 Ko. Le chunk PDF bénéficie d'un budget distinct de 480 Ko, à côté du budget standard inchangé de 320 Ko.

Vérifications :
- Compilation TypeScript et Vite ; budgets de build respectés.
- 28 tests unitaires et invariants du code réussis.
- Suite de régression générale : 40 tests réussis, 2 tests hors ligne ignorés sur les moteurs concernés.
- Tests du lecteur : deux pages réellement dessinées, texte, navigation, zoom, document invalide, chargement bloqué, présentation Espagne/IFSI et rendu du véritable PDF signalé sur Chromium, WebKit et Firefox. Résultats finaux consignés dans la pull request.
- Le fichier local CM9.pdf testé fait 1 880 274 octets. Il n'est ni intégré au dépôt ni envoyé à un prestataire par ce test.
- Un chargement dépassant 30 secondes est interrompu et laisse les actions d'actualisation et d'ouverture externe disponibles.

Les tests locaux n'établissent pas que cette version est déjà publiée. La recette connectée staging et la vérification de version après publication restent requises.

Documentation du moteur : https://mozilla.github.io/pdf.js/getting_started/ et https://mozilla.github.io/pdf.js/api/draft/module-pdfjsLib.html
