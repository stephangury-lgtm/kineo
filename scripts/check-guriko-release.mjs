import { existsSync, readFileSync } from 'node:fs'
import assert from 'node:assert/strict'
import { createHash } from 'node:crypto'

const approvedHashes = {
  180: '67f0e3213281bc96020911cd3d7836b9a78f82f96697cc1424a1898004beae54',
  192: '60b246df1625f18b47c8eb2dafb188a271eff21e85fdcfef05973771be6bacf5',
  512: '641b44a4474e94f91a03b7647799b8f74d846a6d0a370a0fc79e3d76c9fe0543',
  1024: 'dd60eb38dba5e439a6819beaa5aecbd8698a21895e7b26643d909b075d6e8cdd',
}
for (const [size, hash] of Object.entries(approvedHashes)) {
  assert.equal(createHash('sha256').update(readFileSync(`public/icons/guriko-${size}.png`)).digest('hex'), hash, `Approved source altered: ${size}`)
}

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

// Safari may probe the root icon when a shortcut is created from another page.
for(const name of ['apple-touch-icon.png','apple-touch-icon-precomposed.png','apple-touch-icon-180x180.png']){
  const path='public/'+name
  assert.equal(createHash('sha256').update(readFileSync(path)).digest('hex'),approvedHashes[180], 'Apple fallback must be the approved icon: '+path)
  assert.ok(readFileSync('public/sw.js','utf8').includes('/'+name),'Apple fallback missing from offline shell: '+name)
}
const repair=readFileSync('public/repair.html','utf8')
assert.match(repair,/name="apple-mobile-web-app-title" content="GURIKO"/)
assert.match(repair,/rel="apple-touch-icon" sizes="180x180" href="\/icons\/guriko-180\.png"/)
assert.match(repair,/rel="manifest" href="\/manifest\.webmanifest"/)
