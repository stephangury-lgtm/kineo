import {useEffect,useState,type ReactNode} from 'react'
import {Link,Route,Routes,useLocation,type Location} from 'react-router-dom'
import {useDailySession} from './DailySessionContext'

// Keep one quiz mounted inside AuthGate while reading its supporting material.
// Nothing is serialized: logout, refresh, version or program changes discard it.
export default function QuizWorkspace({children}:{children:ReactNode}){
 const location=useLocation()
 const {setResumePath}=useDailySession()
 const onQuiz=location.pathname==='/quiz'
 const [saved,setSaved]=useState<Location|null>(()=>onQuiz?location:null)
 useEffect(()=>{if(onQuiz){setSaved(location);setResumePath(location.pathname+location.search)}},[location,onQuiz,setResumePath])
 const quizLocation=onQuiz?location:saved
 if(!quizLocation)return null
 const reading=['/parcours','/bibliotheque','/lesson/','/cours/','/document/'].some(prefix=>location.pathname.startsWith(prefix))
 return <>
  {!onQuiz&&reading&&<section className="card v5-session-return"><p>Ta révision reste ouverte pendant la consultation des cours.</p><Link className="primary-button" to={quizLocation.pathname+quizLocation.search}>Retour à ma révision</Link></section>}
  <div style={onQuiz?undefined:{display:'none'}} aria-hidden={!onQuiz}>
   <Routes location={quizLocation}><Route path="/quiz" element={<div key={quizLocation.pathname+quizLocation.search}>{children}</div>}/></Routes>
  </div>
 </>
}
