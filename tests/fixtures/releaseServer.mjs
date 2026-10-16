// Local test harness only; this control endpoint is never part of dist/.
import {createServer} from 'node:http'
import {readFile,stat} from 'node:fs/promises'
import path from 'node:path'
import {verifyRelease} from '../../scripts/package-release.mjs'
const root=path.resolve('release-candidates')
for(const variant of ['legacy','v5'])await verifyRelease(path.join(root,variant))
let variant='legacy'
const types={'.html':'text/html','.js':'text/javascript','.css':'text/css','.json':'application/json','.webmanifest':'application/manifest+json','.svg':'image/svg+xml','.png':'image/png','.ico':'image/x-icon'}
createServer(async(req,res)=>{
 try{
  const url=new URL(req.url,'http://127.0.0.1:4180')
  if(url.pathname==='/__test-release'&&req.method==='POST'){
   const selected=url.searchParams.get('variant')
   if(!['legacy','v5'].includes(selected)){res.writeHead(400);res.end();return}
   variant=selected;res.writeHead(204);res.end();return
  }
  const base=path.join(root,variant)
  let file=path.resolve(base,'.'+decodeURIComponent(url.pathname))
  if(file!==base&&!file.startsWith(base+path.sep)){res.writeHead(403);res.end();return}
  try{if(!(await stat(file)).isFile())file=path.join(base,'index.html')}catch{file=path.join(base,'index.html')}
  res.writeHead(200,{'content-type':types[path.extname(file)]??'application/octet-stream','cache-control':'no-store'})
  res.end(await readFile(file))
 }catch{res.writeHead(500);res.end('Local release harness failed')}
}).listen(4180,'127.0.0.1',()=>console.log('Local rollback harness: http://127.0.0.1:4180'))
