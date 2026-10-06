import { useEffect,useState,type ReactNode } from 'react'
import { Navigate } from 'react-router-dom'
import { canReviewVisuals } from '../services/adminApi'

export default function VisualReviewGate({children}:{children:ReactNode}){
 const [state,setState]=useState<'loading'|'allowed'|'denied'>('loading')
 useEffect(()=>{let active=true;canReviewVisuals().then(allowed=>{if(active)setState(allowed?'allowed':'denied')}).catch(()=>{if(active)setState('denied')});return()=>{active=false}},[])
 if(state==='loading')return <section className="card"><p>Vérification de l’accès relecteur…</p></section>
 if(state==='denied')return <Navigate to="/" replace/>
 return <>{children}</>
}
