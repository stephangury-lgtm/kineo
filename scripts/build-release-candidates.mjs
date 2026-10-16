import {spawnSync} from 'node:child_process'
import {cp,rm,mkdir} from 'node:fs/promises'
import path from 'node:path'
if(!process.env.npm_execpath)throw new Error('Run with npm run release:prepare')
const root=path.resolve('release-candidates')
for(const mode of ['legacy','v5']){
 const env={...process.env,VITE_ENABLE_V5_PREVIEW:mode==='v5'?'true':'false',VITE_V5_DEFAULT:mode==='v5'?'true':'false'}
 for(const [command,args] of [[process.env.npm_execpath,['run','build']],['scripts/check-build.mjs',[]],['scripts/package-release.mjs',[]],['scripts/package-release.mjs',['verify']]]){
  const result=spawnSync(process.execPath,[command,...args],{env,stdio:'inherit'})
  if(result.status!==0)throw new Error(`Candidate ${mode} failed: ${command}`)
 }
 const destination=path.resolve(root,mode)
 if(path.dirname(destination)!==root||!['legacy','v5'].includes(path.basename(destination)))throw new Error('Unsafe candidate directory')
 await mkdir(root,{recursive:true})
 await rm(destination,{recursive:true,force:true})
 await cp('dist',destination,{recursive:true})
}
console.log('Both frontend candidates prepared. No upload or deployment performed.')
