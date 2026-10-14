const CACHE = 'kineo-shell-v11'
const SHELL = [
  '/manifest.webmanifest',
  '/offline.html',
  '/startup-recovery.js',
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
    caches.keys().then((keys) => Promise.all(keys.filter((key) => key !== CACHE).map((key) => caches.delete(key)))),
  )
  self.clients.claim()
})

self.addEventListener('fetch', (event) => {
  if (event.request.method !== 'GET') return
  const url = new URL(event.request.url)
  if (url.origin !== self.location.origin) return

  if (event.request.mode === 'navigate') {
    event.respondWith(
      fetch(event.request, { cache: 'no-store' })
        .then((response) => {
          cacheResponse(event, '/', response)
          return response
        })
        .catch(async () => (await caches.match(event.request)) || (await caches.match('/')) || (await caches.match('/offline.html')) || new Response('Connexion Internet nécessaire.', { status: 503, headers: { 'Content-Type': 'text/plain; charset=utf-8' } })),
    )
    return
  }

  if (url.pathname === '/manifest.webmanifest' || url.pathname === '/version.json') {
    event.respondWith(
      fetch(event.request, { cache: 'no-store' })
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
      fetch(event.request, { cache: 'no-store' })
        .then((response) => {
          cacheResponse(event, event.request, response)
          return response
        })
        .catch(() => caches.match(event.request)),
    )
    return
  }

  if (['script', 'style'].includes(event.request.destination)) {
    event.respondWith(
      fetch(event.request, { cache: 'no-store' })
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
