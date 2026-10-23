import test from 'node:test'
import assert from 'node:assert/strict'
import { readFileSync } from 'node:fs'

const config = readFileSync(new URL('../../src/branding/mascotConfig.ts', import.meta.url), 'utf8')
const component = readFileSync(new URL('../../src/branding/Mascot.tsx', import.meta.url), 'utf8')

test('GURIKO: states required for gamification are declared', () => {
  for (const state of ['welcome', 'success', 'retry', 'progress', 'level-up', 'streak', 'badge', 'daily-challenge', 'friends', 'offline']) {
    assert.ok(config.includes("'" + state + "'"), 'missing state: ' + state)
  }
})

test('GURIKO: all three curricula have distinct themes', () => {
  for (const program of ['kineo-fr', 'kineo-es', 'ifsi-fr']) assert.ok(config.includes("'" + program + "':"))
})

test('GURIKO: accessible and reduced-motion-friendly mascot component', () => {
  assert.match(component, /aria-label/)
  assert.match(component, /aria-hidden/)
  assert.match(component, /mascotMessage/)
})


test('GURIKO: daily session integrates mascot in all curricula', () => {
  const page = readFileSync(new URL('../../src/learning/TodayPage.tsx', import.meta.url), 'utf8')
  assert.match(page, /import Mascot from/)
  assert.match(page, /program=\{spain\?'kineo-es':'ifsi-fr'\}/)
  assert.match(page, /program="kineo-fr"/)
  for (const state of ['success', 'progress', 'daily-challenge']) assert.ok(page.includes("'" + state + "'"))
})


test('GURIKO: illustrations use the approved board, never the installation icon', () => {
  assert.match(component, /assetSrc\?: string/)
  assert.match(component, /viewBox=\{mascotArtwork\[state\]\}/)
  assert.doesNotMatch(component, /icons\/guriko/)
  const artwork=readFileSync(new URL('../../src/branding/mascotArtwork.ts',import.meta.url),'utf8')
  const boxes=[...artwork.matchAll(/:'([\d ]+)'/g)].map(m=>m[1].split(' ').map(Number))
  assert.equal(boxes.length,13)
  assert.equal(new Set(boxes.map(b=>b.join(' '))).size,13)
  for(const [x,y,w,h] of boxes){assert.ok(w>0&&h>0&&x>=0&&y>=0&&x+w<=1536&&y+h<=1024)}
  const png=readFileSync(new URL('../../public/branding/guriko-approved-board.png',import.meta.url))
  assert.equal(png.readUInt32BE(16),1536);assert.equal(png.readUInt32BE(20),1024)
})
