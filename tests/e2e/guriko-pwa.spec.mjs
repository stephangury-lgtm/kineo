import { test, expect } from '@playwright/test'
const base = (process.env.KINEO_E2E_BASE_URL || 'http://127.0.0.1:4173').replace(/\/$/, '')

test('GURIKO installation uses decodable approved PNGs on Android and iPhone', async ({ page, request }) => {
  await page.goto(base, { waitUntil: 'networkidle' })
  await expect(page).toHaveTitle(/GURIKO/)
  await expect(page.locator('meta[name="apple-mobile-web-app-title"]')).toHaveAttribute('content', 'GURIKO')
  await expect(page.locator('link[rel="apple-touch-icon"]')).toHaveAttribute('href', '/icons/guriko-180.png')
  const response = await request.get(base + '/manifest.webmanifest')
  expect(response.ok()).toBeTruthy()
  const manifest = await response.json()
  expect(manifest.id).toBe('/')
  expect(manifest.short_name).toBe('GURIKO')
  expect(manifest.icons.find(icon => icon.purpose === 'maskable')?.src).toBe('/icons/guriko-maskable-512.png')
  for (const [src, size] of [...manifest.icons.map(icon => [icon.src, Number(icon.sizes.split('x')[0])]), ['/icons/guriko-180.png', 180]]) {
    const icon = await request.get(base + src)
    expect(icon.ok()).toBeTruthy()
    expect(icon.headers()['content-type']).toContain('image/png')
    const dimensions = await page.evaluate(async src => {
      const image = new Image()
      image.src = src
      await image.decode()
      return [image.naturalWidth, image.naturalHeight]
    }, src)
    expect(dimensions).toEqual([size, size])
  }
})

test('installed GURIKO precaches the current installation icons', async ({ page, browserName }) => {
  test.skip(browserName !== 'chromium', 'Service-worker cache inspection on Chromium')
  await page.goto(base, { waitUntil: 'networkidle' })
  await page.evaluate(async () => { await navigator.serviceWorker.ready })
  const paths = await page.evaluate(async () => {
    const names = await caches.keys()
    const paths = []
    for (const name of names) {
      const cache = await caches.open(name)
      paths.push(...(await cache.keys()).map(request => new URL(request.url).pathname))
    }
    return paths
  })
  for (const path of ['/icons/guriko-180.png', '/icons/guriko-192.png', '/icons/guriko-512.png', '/icons/guriko-maskable-512.png']) expect(paths).toContain(path)
})

test('Safari root icon fallbacks return the approved PNG rather than the SPA HTML', async ({request}) => {
 const canonical=await request.get(base+'/icons/guriko-180.png')
 const expected=await canonical.body()
 for(const path of ['/apple-touch-icon.png','/apple-touch-icon-precomposed.png','/apple-touch-icon-180x180.png']){
  const response=await request.get(base+path)
  expect(response.ok()).toBeTruthy()
  expect(response.headers()['content-type']).toContain('image/png')
  expect(await response.body()).toEqual(expected)
 }
})

test('app and recovery entry pages declare the same iPhone home-screen icon', async ({page}) => {
 for(const path of ['/','/profil','/repair.html']){
  await page.goto(base+path,{waitUntil:'domcontentloaded'})
  await expect(page.locator('meta[name="apple-mobile-web-app-title"]')).toHaveAttribute('content','GURIKO')
  await expect(page.locator('meta[name="apple-mobile-web-app-capable"]')).toHaveAttribute('content','yes')
  await expect(page.locator('link[rel="manifest"]')).toHaveAttribute('href','/manifest.webmanifest')
  await expect(page.locator('link[rel="apple-touch-icon"]')).toHaveAttribute('href','/icons/guriko-180.png')
 }
})
