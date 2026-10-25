import { existsSync, readFileSync } from 'node:fs'
import assert from 'node:assert/strict'
import { createHash } from 'node:crypto'

const approvedHashes = {
  180: 'ce82a0829a741c74066424b13bc64b5d5e7762aea474f247c5dd2a8133d7ad84',
  192: '1312f47fb70fccb8b2b1afc261b23af0705d825a2db8bda0de427c0fccbbb06d',
  512: 'be94011bc8000dcba2982124f2527a6c892bc17e272de08b44bdb26a53d928dc',
  1024: 'be484ced719c0a0fa406558a8ddb7ebd22d1ec0e7619e1ceb81b1775c802aaec',
}
for (const [size, hash] of Object.entries(approvedHashes)) {
  assert.equal(createHash('sha256').update(readFileSync(`public/icons/guriko-v2-${size}.png`)).digest('hex'), hash, `Approved source altered: ${size}`)
}

const manifest = JSON.parse(readFileSync('public/manifest.webmanifest', 'utf8'))
const html = readFileSync('index.html', 'utf8')
assert.equal(manifest.short_name, 'GURIKO')
assert.match(html, /<title>GURIKO/)
assert.match(html, /apple-touch-icon/)
const expected = [
  ['public/icons/guriko-v2-192.png', '192x192'],
  ['public/icons/guriko-v2-512.png', '512x512'],
  ['public/icons/guriko-v2-maskable-512.png', '512x512'],
  ['public/icons/guriko-v2-180.png', '180x180'],
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
assert.ok(manifest.icons.some(icon => icon.src === '/icons/guriko-v2-maskable-512.png' && icon.purpose === 'maskable'))
assert.match(html, /sizes="180x180" href="\/icons\/guriko-v2-180\.png"/)
assert.match(html, /rel="icon" href="\/icons\/guriko-v2-192\.png"/)
assert.ok(manifest.icons.every(icon => icon.src.startsWith('/icons/guriko-v2-') && icon.type === 'image/png'))
console.log('GURIKO approved assets and PWA manifest validated')

// Safari may probe the root icon when a shortcut is created from another page.
for(const name of ['apple-touch-icon.png','apple-touch-icon-precomposed.png','apple-touch-icon-180x180.png']){
  const path='public/'+name
  assert.equal(createHash('sha256').update(readFileSync(path)).digest('hex'),approvedHashes[180], 'Apple fallback must be the approved icon: '+path)
  assert.ok(readFileSync('public/sw.js','utf8').includes('/'+name),'Apple fallback missing from offline shell: '+name)
}
const repair=readFileSync('public/repair.html','utf8')
assert.match(repair,/name="apple-mobile-web-app-title" content="GURIKO"/)
assert.match(repair,/rel="apple-touch-icon" sizes="180x180" href="\/icons\/guriko-v2-180\.png"/)
assert.match(repair,/rel="manifest" href="\/manifest\.webmanifest"/)
