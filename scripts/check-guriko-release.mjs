import { existsSync, readFileSync } from 'node:fs'
import assert from 'node:assert/strict'

const manifest = JSON.parse(readFileSync('public/manifest.webmanifest', 'utf8'))
const html = readFileSync('index.html', 'utf8')
assert.equal(manifest.short_name, 'GURIKO')
assert.match(html, /<title>GURIKO/)
assert.match(html, /apple-touch-icon/)
const expected = [
  ['public/icons/guriko-192.png', '192x192'],
  ['public/icons/guriko-512.png', '512x512'],
  ['public/icons/guriko-maskable-512.png', '512x512'],
  ['public/icons/guriko-180.png', '180x180'],
]
for (const [path, size] of expected) {
  assert.ok(existsSync(path), 'Missing approved GURIKO icon: ' + path)
  const png = readFileSync(path)
  assert.equal(png.subarray(0, 8).toString('hex'), '89504e470d0a1a0a', 'Invalid PNG: ' + path)
  assert.equal(`${png.readUInt32BE(16)}x${png.readUInt32BE(20)}`, size, 'Incorrect PNG dimensions: ' + path)
  assert.ok(readFileSync('public/sw.js', 'utf8').includes('/' + path.replace(/^public\//, '')), 'Icon missing from offline shell: ' + path)
}
for (const [path, size] of expected.slice(0, 3)) {
  const src = '/' + path.replace(/^public\//, '')
  assert.ok(manifest.icons.some(icon => icon.src === src && icon.sizes === size), 'Missing manifest icon: ' + src)
}
assert.ok(manifest.icons.some(icon => icon.src === '/icons/guriko-maskable-512.png' && icon.purpose === 'maskable'))
assert.match(html, /sizes="180x180" href="\/icons\/guriko-180\.png"/)
assert.match(html, /rel="icon" href="\/icons\/guriko-192\.png"/)
assert.ok(manifest.icons.every(icon => icon.src.startsWith('/icons/guriko-') && icon.type === 'image/png'))
console.log('GURIKO approved assets and PWA manifest validated')
