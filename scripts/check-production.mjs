const base=(process.env.KINEO_BASE_URL||'https://kineo.stephangury.workers.dev').replace(/\/$/,'')
const expected=(process.env.EXPECTED_SHA||'').slice(0,7)
const routes=['/','/parcours','/fondamentaux','/stats','/rewards','/amis','/profil','/notifications']

async function fetchOk(path,accept='text/html'){
 const response=await fetch(`${base}${path}`,{headers:{accept},cache:'no-store',redirect:'manual'})
 if(!response.ok)throw new Error(`${path} returned ${response.status}`)
 return response
}

let homeHtml=''
for(const route of routes){
 const response=await fetchOk(route)
 const html=await response.text()
 if(route==='/')homeHtml=html
 if(!html.includes('<div id="root"></div>'))throw new Error(`${route} is not serving the Kineo SPA shell`)
 const contentType=response.headers.get('content-type')||''
 if(!contentType.includes('text/html'))throw new Error(`${route} has unexpected content type: ${contentType}`)
}

const scriptPaths=[...homeHtml.matchAll(/<script[^>]+src=["']([^"']+)["']/g)].map(match=>match[1])
if(scriptPaths.length===0)throw new Error('Production HTML references no JavaScript entry asset')
for(const assetPath of scriptPaths){
 const response=await fetchOk(assetPath,'text/javascript')
 const contentType=response.headers.get('content-type')||''
 if(!/javascript|ecmascript/.test(contentType))throw new Error(`${assetPath} has invalid JavaScript MIME type: ${contentType}`)
 const body=await response.text()
 if(body.trim().startsWith('<!doctype')||body.includes('<div id="root"></div>'))throw new Error(`${assetPath} incorrectly serves the SPA HTML fallback`)
}

const securityHeaders=await fetchOk('/')
for(const header of ['x-content-type-options','x-frame-options','referrer-policy']){
 if(!securityHeaders.headers.get(header))throw new Error(`Production security header missing: ${header}`)
}

const versionResponse=await fetchOk(`/version.json?health=${Date.now()}`,'application/json')
const version=await versionResponse.json()
if(!version.version||!version.commit)throw new Error('Production version.json is incomplete')
if(expected&&!String(version.commit).startsWith(expected))throw new Error(`Production commit mismatch: expected ${expected}, got ${version.commit}`)

const swResponse=await fetchOk(`/sw.js?health=${Date.now()}`,'text/javascript')
const sw=await swResponse.text()
if(!sw.includes(`kineo-shell-${String(version.commit).slice(0,7)}`))throw new Error('Production service worker cache is stale')

console.log(`Production smoke checks passed for ${version.version}`)
