import fs from 'node:fs'
import path from 'node:path'

const root=process.cwd()
const dist=path.join(root,'dist')
const required=['index.html','version.json','sw.js']
for(const file of required){
 const full=path.join(dist,file)
 if(!fs.existsSync(full)) throw new Error(`Missing production artifact: ${file}`)
 if(fs.statSync(full).size===0) throw new Error(`Empty production artifact: ${file}`)
}

const version=JSON.parse(fs.readFileSync(path.join(dist,'version.json'),'utf8'))
const expected=(process.env.GITHUB_SHA||process.env.KINEO_BUILD_SHA||'').slice(0,7)
if(!version.version || !version.commit) throw new Error('version.json is missing version or commit')
if(expected && !version.commit.startsWith(expected)){
 throw new Error(`Build stamp mismatch: expected ${expected}, got ${version.commit}`)
}

const sw=fs.readFileSync(path.join(dist,'sw.js'),'utf8')
const shortCommit=version.commit.slice(0,7)
if(!sw.includes(`kineo-shell-${shortCommit}`)){
 throw new Error(`Service worker cache is not stamped with ${shortCommit}`)
}
if(!sw.includes('version.json')) throw new Error('Service worker does not handle version.json')

const html=fs.readFileSync(path.join(dist,'index.html'),'utf8')
if(!html.includes('<div id="root"></div>')) throw new Error('Production index is missing React root')

console.log(`Build smoke checks passed for ${version.version}`)
