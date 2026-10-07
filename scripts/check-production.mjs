const base=(process.env.KINEO_BASE_URL||'https://kineo.stephangury.workers.dev').replace(/\/$/,'')
const expected=(process.env.EXPECTED_SHA||'').slice(0,7)
const routes=['/','/parcours','/fondamentaux','/stats','/rewards','/amis','/profil','/notifications']

async function fetchOk(path,accept='text/html'){
 const response=await fetch(`${base}${path}`,{headers:{accept},cache:'no-store',redirect:'manual'})
 if(!response.ok)throw new Error(`${path} returned ${response.status}`)
 return response
}

for(const route of routes){
 const response=await fetchOk(route)
 const html=await response.text()
 if(!html.includes('<div id="root"></div>'))throw new Error(`${route} is not serving the Kineo SPA shell`)
}

const versionResponse=await fetchOk(`/version.json?health=${Date.now()}`,'application/json')
const version=await versionResponse.json()
if(!version.version||!version.commit)throw new Error('Production version.json is incomplete')
if(expected&&!String(version.commit).startsWith(expected))throw new Error(`Production commit mismatch: expected ${expected}, got ${version.commit}`)

const swResponse=await fetchOk(`/sw.js?health=${Date.now()}`,'text/javascript')
const sw=await swResponse.text()
if(!sw.includes(`kineo-shell-${String(version.commit).slice(0,7)}`))throw new Error('Production service worker cache is stale')

console.log(`Production smoke checks passed for ${version.version}`)
