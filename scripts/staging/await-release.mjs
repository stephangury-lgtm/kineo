export async function awaitRelease({url,sha,interface:mode,attempts=8,fetcher=fetch,delay=()=>new Promise(resolve=>setTimeout(resolve,2000))}){
 if(!/^[a-f0-9]{40}$/.test(sha)||!['legacy','v5'].includes(mode))throw Error('Exact release identity required')
 if(!Number.isInteger(attempts)||attempts<1||attempts>8)throw Error('Invalid release check bound')
 for(let attempt=0;attempt<attempts;attempt++){
  const target=new URL(url)
  target.searchParams.set('release_check',sha+'-'+attempt)
  try{
   const response=await fetcher(target,{cache:'no-store',signal:AbortSignal.timeout(15000)})
   if(response.ok){const live=await response.json();if(live.commit===sha&&live.interface===mode)return live}
  }catch{}
  if(attempt+1<attempts)await delay()
 }
 throw Error('Expected release identity not visible after bounded propagation checks')
}

