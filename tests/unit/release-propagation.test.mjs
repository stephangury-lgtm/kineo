import test from 'node:test'
import assert from 'node:assert/strict'
import {awaitRelease} from '../../scripts/staging/await-release.mjs'
const sha='a'.repeat(40)
test('propagation retries only accept the exact commit and interface',async()=>{
 let count=0
 const live=await awaitRelease({url:'https://example.invalid/version.json',sha,interface:'legacy',delay:async()=>{},fetcher:async url=>{
  assert.match(String(url),/release_check=/)
  count++
  return new Response(JSON.stringify({commit:count===1?'b'.repeat(40):sha,interface:'legacy'}))
 }})
 assert.equal(count,2)
 assert.equal(live.commit,sha)
})
test('wrong interface remains a failure after the finite propagation window',async()=>{
 let count=0
 await assert.rejects(awaitRelease({url:'https://example.invalid/version.json',sha,interface:'legacy',attempts:3,delay:async()=>{},fetcher:async()=>{
  count++;return new Response(JSON.stringify({commit:sha,interface:'v5'}))
 }}),/Expected release identity/)
 assert.equal(count,3)
})

