// Deliberately independent of React and of authenticated APIs: recovery must
// work even when the main entry bundle never executes. Never clear user storage.
(function () {
  var button = document.getElementById('repair');
  var status = document.getElementById('status');
  button.addEventListener('click', function () {
    button.disabled = true;
    status.textContent = 'Renouvellement des fichiers de démarrage…';
    var tasks = [];
    if ('serviceWorker' in navigator) {
      tasks.push(navigator.serviceWorker.getRegistrations().then(function (registrations) {
        return Promise.all(registrations.filter(function (registration) {
          return registration.scope === location.origin + '/';
        }).map(function (registration) { return registration.unregister(); }));
      }));
    }
    if ('caches' in window) {
      tasks.push(caches.keys().then(function (names) {
        return Promise.all(names.filter(function (name) { return name.indexOf('kineo-shell-') === 0; }).map(function (name) { return caches.delete(name); }));
      }));
    }
    var timer = window.setTimeout(function () {
      status.textContent = 'Le nettoyage prend plus de temps que prévu. Ferme complètement GURIKO, puis utilise le lien ci-dessous.';
      button.disabled = false;
    }, 6000);
    Promise.all(tasks).then(function () {
      window.clearTimeout(timer);
      status.textContent = 'Fichiers renouvelés. Ouverture de GURIKO…';
      location.replace('/?repaired=' + Date.now());
    }).catch(function () {
      window.clearTimeout(timer);
      button.disabled = false;
      status.textContent = 'Le nettoyage n’a pas pu se terminer. Réessaie ou ouvre GURIKO avec le lien ci-dessous.';
    });
  });
})();
