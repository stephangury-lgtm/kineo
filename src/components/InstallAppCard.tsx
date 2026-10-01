import { useEffect,useState } from 'react'

type InstallPromptEvent = Event & {
  prompt: () => Promise<void>
  userChoice: Promise<{ outcome: 'accepted' | 'dismissed'; platform: string }>
}

function isStandalone(){
  return window.matchMedia('(display-mode: standalone)').matches || Boolean((navigator as Navigator & { standalone?: boolean }).standalone)
}

export default function InstallAppCard(){
  const [promptEvent,setPromptEvent]=useState<InstallPromptEvent|null>(null)
  const [installed,setInstalled]=useState(()=>typeof window!=='undefined'&&isStandalone())
  const [showIos,setShowIos]=useState(false)

  useEffect(()=>{
    if(isStandalone()){setInstalled(true);return}
    const ua=navigator.userAgent
    const ios=/iPad|iPhone|iPod/.test(ua) || (navigator.platform==='MacIntel'&&navigator.maxTouchPoints>1)
    setShowIos(ios)
    const before=(event:Event)=>{event.preventDefault();setPromptEvent(event as InstallPromptEvent)}
    const done=()=>{setInstalled(true);setPromptEvent(null);setShowIos(false)}
    window.addEventListener('beforeinstallprompt',before)
    window.addEventListener('appinstalled',done)
    return()=>{window.removeEventListener('beforeinstallprompt',before);window.removeEventListener('appinstalled',done)}
  },[])

  async function install(){
    if(!promptEvent)return
    await promptEvent.prompt()
    const choice=await promptEvent.userChoice
    if(choice.outcome==='accepted')setPromptEvent(null)
  }

  if(installed||(!promptEvent&&!showIos))return null
  return <section className="card challenge-card"><div className="challenge-icon">📲</div><div className="challenge-copy"><p className="eyebrow">Installer Kineo</p><h2>Kineo directement sur ton écran d’accueil</h2><p>{showIos&&!promptEvent?'Sur iPhone/iPad : touche Partager puis « Sur l’écran d’accueil ».':'Installe la PWA pour l’ouvrir comme une application et profiter plus facilement du mode hors ligne.'}</p></div>{promptEvent&&<button className="secondary-button" onClick={()=>void install()}>Installer</button>}</section>
}
