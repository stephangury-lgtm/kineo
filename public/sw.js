const CACHE = 'kineo-shell-v5'
const SHELL = [
  '/',
  '/manifest.webmanifest',
  '/kineo-icon.svg',
  '/quiz-assets/hotspot-cheville-malleoles.svg',
  '/quiz-assets/hotspot-cheville.svg',
  '/quiz-assets/hotspot-genou-menisques.svg',
  '/quiz-assets/hotspot-genou.svg',
  '/quiz-assets/hotspot-hanche-proximal.svg',
  '/quiz-assets/hotspot-hanche.svg',
  '/quiz-assets/hotspot-pied-tarse-extended.svg',
  '/quiz-assets/hotspot-pied.svg',
]

self.addEventListener('install', (event) => {
  event.waitUntil(caches.open(CACHE).then((cache) => cache.addAll(SHELL)))
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
          if (response.ok) caches.open(CACHE).then((cache) => cache.put('/', response.clone()))
          return response
        })
        .catch(() => caches.match(event.request).then((cached) => cached || caches.match('/'))),
    )
    return
  }

  if (['script', 'style'].includes(event.request.destination)) {
    event.respondWith(
      fetch(event.request, { cache: 'no-store' })
        .then((response) => {
          if (response.ok) caches.open(CACHE).then((cache) => cache.put(event.request, response.clone()))
          return response
        })
        .catch(() => caches.match(event.request)),
    )
    return
  }

  if (['image', 'font'].includes(event.request.destination)) {
    event.respondWith(
      caches.match(event.request).then((cached) => cached || fetch(event.request).then((response) => {
        if (response.ok) caches.open(CACHE).then((cache) => cache.put(event.request, response.clone()))
        return response
      })),
    )
    return
  }

  event.respondWith(
    caches.match(event.request).then((cached) => cached || fetch(event.request).then((response) => {
      if (response.ok) caches.open(CACHE).then((cache) => cache.put(event.request, response.clone()))
      return response
    })),
  )
})
