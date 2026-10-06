import { spawn } from 'node:child_process'

const host='127.0.0.1'
const port=4173
const base=`http://${host}:${port}`
const server=spawn('npm',['run','preview','--','--host',host,'--port',String(port),'--strictPort'],{stdio:['ignore','pipe','pipe']})
let output=''
server.stdout.on('data',chunk=>{output+=chunk.toString()})
server.stderr.on('data',chunk=>{output+=chunk.toString()})

const sleep=ms=>new Promise(resolve=>setTimeout(resolve,ms))
async function waitForServer(){
 for(let attempt=0;attempt<40;attempt++){
  try{
   const response=await fetch(base,{redirect:'manual'})
   if(response.ok)return
  }catch{}
  await sleep(250)
 }
 throw new Error(`Preview server did not start. Output:\n${output}`)
}

async function expectHtml(route){
 const response=await fetch(`${base}${route}`,{headers:{accept:'text/html'}})
 if(!response.ok)throw new Error(`${route} returned ${response.status}`)
 const text=await response.text()
 if(!text.includes('<div id="root"></div>'))throw new Error(`${route} is not serving the SPA shell`)
}

try{
 await waitForServer()
 for(const route of ['/','/profil','/amis','/stats','/revision'])await expectHtml(route)
 const versionResponse=await fetch(`${base}/version.json`,{cache:'no-store'})
 if(!versionResponse.ok)throw new Error(`version.json returned ${versionResponse.status}`)
 const version=await versionResponse.json()
 if(!version.version||!version.commit)throw new Error('version.json is incomplete in preview')
 const swResponse=await fetch(`${base}/sw.js`,{cache:'no-store'})
 if(!swResponse.ok)throw new Error(`sw.js returned ${swResponse.status}`)
 const sw=await swResponse.text()
 if(!sw.includes(`kineo-shell-${String(version.commit).slice(0,7)}`))throw new Error('Preview service worker cache does not match build version')
 console.log(`Preview route checks passed for ${version.version}`)
}finally{
 server.kill('SIGTERM')
 await Promise.race([new Promise(resolve=>server.once('exit',resolve)),sleep(1500)])
 if(!server.killed)server.kill('SIGKILL')
}
