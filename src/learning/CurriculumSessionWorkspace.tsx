import {lazy,useEffect,useState} from 'react'
import {Link,Route,Routes,useLocation,type Location} from 'react-router-dom'
const FoundationsPage=lazy(()=>import('../pages/FoundationsPage'))
import {getCurrentProgram} from '../curriculum/programs'
import {useDailySession} from './DailySessionContext'
// Keep questions mounted inside AuthGate, without serializing student answers.
export default function CurriculumSessionWorkspace(){
 const location=useLocation(),spain=getCurrentProgram().id==='kineo-es', {state}=useDailySession()
 const daily=location.pathname==='/fondamentaux'&&new URLSearchParams(location.search).get('daily')==='1'
 const [saved,setSaved]=useState<Location|null>(()=>daily?location:null)
 useEffect(()=>{if(daily)setSaved(location)},[daily,location])
 const current=daily?location:saved
 if(!current)return null
 return <>{!daily&&location.pathname!=='/ma-seance'&&state.status==='in_progress'&&<aside className="v5-daily-return"><Link to={current.pathname+current.search}>{spain?'Continuar mi sesión':'Reprendre ma séance'} →</Link></aside>}<div hidden={!daily}><Routes location={current}><Route path="/fondamentaux" element={<FoundationsPage/>}/></Routes></div></>
}
