// Runs before the application bundle so an outdated iOS home-screen installation can recover.
(function () {
  var key = 'leryko_startup_recovery_at';
  var recovering = false;
  function recover() {
    if (recovering || navigator.onLine === false) return;
    var now = Date.now();
    try {
      if (now - Number(sessionStorage.getItem(key) || 0) < 120000) return;
      sessionStorage.setItem(key, String(now));
    } catch (_) { return; }
    recovering = true;
    var cleanup = [];
    if ('serviceWorker' in navigator) {
      cleanup.push(navigator.serviceWorker.getRegistrations().then(function (items) {
        return Promise.all(items.map(function (registration) { return registration.unregister(); }));
      }));
    }
    if ('caches' in window) {
      cleanup.push(caches.keys().then(function (keys) {
        return Promise.all(keys.filter(function (name) { return name.indexOf('kineo-shell-') === 0; }).map(function (name) { return caches.delete(name); }));
      }));
    }
    Promise.allSettled(cleanup).then(function () {
      var url = new URL(location.href);
      url.searchParams.set('recovery', String(now));
      location.replace(url.toString());
    });
  }
  window.addEventListener('error', function (event) {
    var message = String(event.message || (event.error && event.error.message) || '');
    var target = event.target;
    var assetFailed = target && target !== window && (target.tagName === 'SCRIPT' || target.tagName === 'LINK');
    if (assetFailed || /Importing a module script failed|Failed to fetch dynamically imported module|Unable to preload CSS|Loading chunk .* failed|Failed to fetch module/i.test(message)) recover();
  }, true);
  window.addEventListener('unhandledrejection', function (event) {
    var reason = event.reason;
    var message = String(reason && reason.message || reason || '');
    if (/Importing a module script failed|Failed to fetch dynamically imported module|Unable to preload CSS|Loading chunk .* failed/i.test(message)) recover();
  });
})();
