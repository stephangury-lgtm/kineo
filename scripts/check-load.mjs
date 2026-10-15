// Small read-only availability probe. This is not a capacity/stress test.
const base=(process.env.KINEO_BASE_URL||'http://127.0.0.1:4173').replace(/\/$/,'')
if(!/^https?:\/\/(localhost|127\.0\.0\.1)(:|\/|$)/.test(base)&&process.env.LERYKO_ALLOW_PRODUCTION_PROBE!=='yes')throw new Error('Explicit production probe opt-in required')
const paths=['/','/informations','/manifest.webmanifest','/version.json']
const results=[]
let next=0
await Promise.all(Array.from({length:4},async()=>{
 while(next<20){
  const index=next++,start=performance.now()
  try{
   const response=await fetch(base+paths[index%paths.length],{signal:AbortSignal.timeout(15000),cache:'no-store'})
   await response.arrayBuffer()
   results.push({ok:response.ok,ms:Math.round(performance.now()-start),status:response.status})
  }catch{results.push({ok:false,ms:Math.round(performance.now()-start),status:0})}
 }
}))
const durations=results.map(x=>x.ms).sort((a,b)=>a-b),failed=results.filter(x=>!x.ok).length
console.log(JSON.stringify({requests:20,concurrency:4,failed,p50_ms:durations[9],p95_ms:durations[18],max_ms:durations[19],scope:'public HTTP reads only; no authenticated capacity claim'}))
if(failed||durations[18]>15000)process.exitCode=1
