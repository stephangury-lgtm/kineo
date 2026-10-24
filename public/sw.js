const CACHE = 'kineo-shell-v11'
const SHELL = [
  '/branding/guriko-approved-board.png',
  '/icons/guriko-180.png',
  '/apple-touch-icon.png',
  '/apple-touch-icon-precomposed.png',
  '/apple-touch-icon-180x180.png',
  '/icons/guriko-192.png',
  '/icons/guriko-512.png',
  '/icons/guriko-maskable-512.png',
  '/manifest.webmanifest',
  '/offline.html',
  '/startup-recovery.js',
  '/repair.html',
  '/pwa-repair.js',
  '/leryko-brand-logo.svg',
  '/icons/leryko-launch.svg',
  '/kineo-icon.svg',
  '/icons/kineo-192.png',
  '/icons/kineo-512.png',
  '/icons/kineo-maskable-512.png',
  '/icons/apple-touch-icon-180.png',
  '/icons/favicon-32.png',
]

function cacheResponse(event, key, response) {
  if (!response.ok) return
  // Clone while the body is still unused, before returning it to the browser.
  const copy = response.clone()
  event.waitUntil(caches.open(CACHE).then((cache) => cache.put(key, copy)).catch(() => undefined))
}

async function precacheShell() {
  const cache = await caches.open(CACHE)
  await cache.addAll(SHELL)
  const response = await fetch('/', { cache: 'no-store' })
  if (!response.ok) throw new Error('Application shell unavailable')
  await cache.put('/', response.clone())
  const html = await response.text()
  const assets = [...html.matchAll(/(?:src|href)=["'](\/assets\/[^"']+)["']/g)].map((match) => match[1])
  await cache.addAll([...new Set(assets)])
}

self.addEventListener('install', (event) => {
  event.waitUntil(precacheShell())
  self.skipWaiting()
})

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((keys) => Promise.all(keys.filter((key) => key.startsWith('kineo-shell-') && key !== CACHE).map((key) => caches.delete(key)))),
  )
  self.clients.claim()
})

// A suspended connection can remain pending while Android displays its launch
// screen. Rejection-only fallback never runs in that case, so bound the wait.
function fetchWithDeadline(request) {
  const controller = new AbortController()
  let timer
  const deadline = new Promise((_, reject) => {
    timer = setTimeout(() => {
      controller.abort()
      reject(new Error('Application network timeout'))
    }, 4000)
  })
  return Promise.race([fetch(request, { cache: 'no-store', signal: controller.signal }), deadline])
    .then((response) => {
      if (!response.ok) throw new Error('Application response unavailable')
      return response
    })
    .finally(() => clearTimeout(timer))
}

// Navigation responses must not carry a followed-redirect flag. WebKit rejects
// them before rendering the page, including when they came from Cache Storage.
function navigationResponse(response) {
  return response && response.redirected
    ? new Response(response.body, { status: response.status, statusText: response.statusText, headers: response.headers })
    : response
}

self.addEventListener('fetch', (event) => {
  if (event.request.method !== 'GET') return
  const url = new URL(event.request.url)
  if (url.origin !== self.location.origin) return

  if (event.request.mode === 'navigate') {
    const cacheKey = ['/repair', '/repair.html'].includes(url.pathname) ? '/repair.html' : '/'
    event.respondWith(
      fetchWithDeadline(event.request)
        .then(navigationResponse)
        .then((response) => {
          cacheResponse(event, cacheKey, response)
          return response
        })
        .catch(async () => (await caches.match(event.request)) || (await caches.match(cacheKey)) || (await caches.match('/')) || (await caches.match('/offline.html')) || new Response('Connexion Internet nécessaire.', { status: 503, headers: { 'Content-Type': 'text/plain; charset=utf-8' } }))
        .then(navigationResponse),
    )
    return
  }

  if (url.pathname === '/manifest.webmanifest' || url.pathname === '/version.json') {
    event.respondWith(
      fetchWithDeadline(event.request)
        .then((response) => {
          cacheResponse(event, event.request, response)
          return response
        })
        .catch(() => caches.match(event.request)),
    )
    return
  }

  if (url.pathname.startsWith('/quiz-assets/')) {
    event.respondWith(
      fetchWithDeadline(event.request)
        .then((response) => {
          cacheResponse(event, event.request, response)
          return response
        })
        .catch(() => caches.match(event.request)),
    )
    return
  }

  if (['script', 'style'].includes(event.request.destination)) {
    // Vite filenames contain their content hash. The exact cached URL is safe
    // to reuse and must not wait on the network on every installed-app launch.
    if (url.pathname.startsWith('/assets/')) {
      event.respondWith(caches.match(event.request).then((cached) => cached || fetchWithDeadline(event.request).then((response) => {
        cacheResponse(event, event.request, response)
        return response
      })))
      return
    }
    event.respondWith(
      fetchWithDeadline(event.request)
        .then((response) => {
          cacheResponse(event, event.request, response)
          return response
        })
        .catch(() => caches.match(event.request)),
    )
    return
  }

  if (['image', 'font'].includes(event.request.destination)) {
    event.respondWith(
      caches.match(event.request).then((cached) => cached || fetch(event.request).then((response) => {
        cacheResponse(event, event.request, response)
        return response
      })),
    )
    return
  }

  event.respondWith(
    caches.match(event.request).then((cached) => cached || fetch(event.request).then((response) => {
      cacheResponse(event, event.request, response)
      return response
    })),
  )
})
