import { readFile, writeFile } from 'node:fs/promises'
import { execFileSync } from 'node:child_process'

function resolveSha(){
  const envSha=process.env.GITHUB_SHA?.trim()
  if(envSha)return envSha
  try{return execFileSync('git',['rev-parse','HEAD'],{encoding:'utf8'}).trim()}
  catch{return 'local'}
}

const sha=resolveSha()
const shortSha=sha==='local'?'local':sha.slice(0,7)
const now=new Date()
const date=now.toISOString().slice(0,10)
const version=`KINEO-V2-${date.replaceAll('-','.')}-${shortSha}`
const cache=`kineo-shell-${shortSha}`

await writeFile('dist/version.json',JSON.stringify({version,date,branch:process.env.GITHUB_REF_NAME??'local',commit:sha},null,2)+'\n','utf8')

const swPath='dist/sw.js'
const sw=await readFile(swPath,'utf8')
const stamped=sw.replace(/const CACHE = ['"][^'"]+['"]/,`const CACHE = '${cache}'`)
if(stamped===sw)throw new Error('Unable to stamp service-worker cache version')
await writeFile(swPath,stamped,'utf8')

console.log(`Stamped ${version} with cache ${cache}`)
