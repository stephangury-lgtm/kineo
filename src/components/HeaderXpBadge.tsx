import { useCallback,useEffect,useState } from 'react'
import { getGamificationSummaryV2 } from '../services/kineoApi'
import { getCurrentProgram } from '../curriculum/programs'
import { useInterfaceVersion } from '../learning/InterfaceVersion'
import { Link } from 'react-router-dom'

export default function HeaderXpBadge(){
 const {v5}=useInterfaceVersion()
 const isSpain=getCurrentProgram().id==='kineo-es'
 const [xp,setXp]=useState<number|null>(null)
 const [streak,setStreak]=useState<number|null>(null)
 useEffect(()=>{
  let active=true
  const refresh=()=>{getGamificationSummaryV2().then(summary=>{if(active){setXp(summary.xp_total??0);setStreak(summary.streak.current)}}).catch(()=>undefined)}
  refresh()
  window.addEventListener('kineo:xp-updated',refresh)
  window.addEventListener('focus',refresh)
  return()=>{active=false;window.removeEventListener('kineo:xp-updated',refresh);window.removeEventListener('focus',refresh)}
 },[])
 if(xp===null)return null
 return <>{v5&&streak!==null&&<Link className="header-streak-badge" to="/progres" aria-label={isSpain?`${streak} días seguidos, ver mi progreso`:`${streak} jours de suite, voir mes progrès`}>🔥 {streak}</Link>}<span className="header-xp-badge" aria-label={isSpain?`${xp} puntos de experiencia`:`${xp} points d'expérience`}>⚡ {xp} XP</span></>
}
