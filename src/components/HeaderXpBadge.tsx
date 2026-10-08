import { useCallback,useEffect,useState } from 'react'
import { getGamificationSummaryV2 } from '../services/kineoApi'
import { getCurrentProgram } from '../curriculum/programs'

export default function HeaderXpBadge(){
 const isSpain=getCurrentProgram().id==='kineo-es'
 const [xp,setXp]=useState<number|null>(null)
 useEffect(()=>{
  let active=true
  const refresh=()=>{getGamificationSummaryV2().then(summary=>{if(active)setXp(summary.xp_total??0)}).catch(()=>undefined)}
  refresh()
  window.addEventListener('kineo:xp-updated',refresh)
  window.addEventListener('focus',refresh)
  return()=>{active=false;window.removeEventListener('kineo:xp-updated',refresh);window.removeEventListener('focus',refresh)}
 },[])
 if(xp===null)return null
 return <span className="header-xp-badge" aria-label={isSpain?`${xp} puntos de experiencia`:`${xp} points d'expérience`}>⚡ {xp} XP</span>
}
