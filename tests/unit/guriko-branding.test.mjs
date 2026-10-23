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


test('GURIKO: missing illustration assets do not trigger implicit 404 requests', () => {
  assert.match(component, /assetSrc\?: string/)
  assert.match(component, /\{assetSrc && <img/)
  assert.doesNotMatch(component, /src=\{\x60\/branding\/mascot\//)
})
