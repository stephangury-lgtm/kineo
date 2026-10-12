// Runs before the application bundle so an outdated iOS home-screen installation can recover.
(function () {
  var key = 'leryko_startup_recovery_at';
  var recovering = false;
  function recover() {
    if (recovering || navigator.onLine === false) return;
    var now = Date.now();
    // The URL marker also prevents reload loops when iOS blocks sessionStorage.
    var url = new URL(location.href);
    var lastRecovery = Number(url.searchParams.get('recovery') || 0);
    if (lastRecovery && now - lastRecovery < 120000) return;
    try {
      if (now - Number(sessionStorage.getItem(key) || 0) < 120000) return;
      sessionStorage.setItem(key, String(now));
    } catch (_) { /* iOS storage can be unavailable; the URL guard remains active. */ }
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
    Promise.all(cleanup.map(function (operation) { return operation.catch(function () { return null; }); })).then(function () {
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
  // A missing entry bundle may emit no useful error event on Safari standalone.
  // Keep a manual recovery path even when the JavaScript application never mounts.
  window.setTimeout(function () {
    var help = document.getElementById('startup-help');
    if (!help || !help.isConnected || document.getElementById('startup-recovery-button')) return;
    var button = document.createElement('button');
    button.id = 'startup-recovery-button';
    button.type = 'button';
    button.textContent = 'Réparer le démarrage';
    button.style.cssText = 'display:block;margin:20px auto;padding:12px 20px;border:0;border-radius:12px;background:#0f4c3a;color:#fff;font:600 16px system-ui,sans-serif';
    button.addEventListener('click', recover);
    help.appendChild(button);
  }, 8000);
  window.setTimeout(function () {
    if (document.getElementById('startup-help')) recover();
  }, 16000);
})();
