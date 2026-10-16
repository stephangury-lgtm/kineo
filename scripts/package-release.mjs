import {createHash} from 'node:crypto'
import {readdir,readFile,writeFile} from 'node:fs/promises'
import path from 'node:path'
import {pathToFileURL} from 'node:url'

async function files(root,prefix=''){
 const result=[]
 for(const entry of await readdir(path.join(root,prefix),{withFileTypes:true})){
  const relative=prefix?`${prefix}/${entry.name}`:entry.name
  if(entry.isSymbolicLink())throw new Error('Release symlinks are not allowed')
  if(entry.isDirectory())result.push(...await files(root,relative))
  else if(entry.isFile()&&relative!=='release-manifest.json')result.push(relative)
 }
 return result.sort()
}
async function digest(root){
 const result={}
 for(const file of await files(root))result[file]=createHash('sha256').update(await readFile(path.join(root,file))).digest('hex')
 return result
}
export async function packageRelease(root){
 const version=JSON.parse(await readFile(path.join(root,'version.json'),'utf8'))
 if(!/^[a-f0-9]{40}$/.test(version.commit)||!['legacy','preview','v5'].includes(version.interface))throw new Error('Invalid release identity')
 const manifest={schema:1,commit:version.commit,interface:version.interface,cache:version.cache,files:await digest(root)}
 await writeFile(path.join(root,'release-manifest.json'),JSON.stringify(manifest,null,2)+'\n')
 return manifest
}
export async function verifyRelease(root){
 const manifest=JSON.parse(await readFile(path.join(root,'release-manifest.json'),'utf8'))
 const actual=await digest(root)
 if(manifest.schema!==1||JSON.stringify(actual)!==JSON.stringify(manifest.files))throw new Error('Release contents do not match checksums')
 const version=JSON.parse(await readFile(path.join(root,'version.json'),'utf8'))
 if(manifest.commit!==version.commit||manifest.interface!==version.interface||manifest.cache!==version.cache)throw new Error('Release identity mismatch')
 return manifest
}
if(process.argv[1]&&import.meta.url===pathToFileURL(path.resolve(process.argv[1])).href){
 const result=process.argv[2]==='verify'?await verifyRelease('dist'):await packageRelease('dist')
 console.log(`Release ${result.commit} / ${result.interface}: checksums verified`)
}
