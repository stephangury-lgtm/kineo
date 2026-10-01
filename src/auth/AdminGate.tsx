import { useEffect,useState,type ReactNode } from 'react'
import { Navigate } from 'react-router-dom'
import { getCurrentProfile } from '../services/profileApi'

export default function AdminGate({children}:{children:ReactNode}){
 const [state,setState]=useState<'loading'|'admin'|'denied'>('loading')
 useEffect(()=>{let active=true;getCurrentProfile().then(profile=>{if(active)setState(profile?.role==='admin'?'admin':'denied')}).catch(()=>{if(active)setState('denied')});return()=>{active=false}},[])
 if(state==='loading')return <section className="card"><p>Vérification de l’accès administrateur…</p></section>
 if(state==='denied')return <Navigate to="/" replace/>
 return <>{children}</>
}
