import { useEffect, useState } from 'react'
import { useLocation } from 'react-router-dom'
import { supabase } from '../lib/supabase'
import { getCurrentProgram } from '../curriculum/programs'
import './ReminderOptInInvite.css'

export default function ReminderOptInInvite(){
 const location=useLocation()
 const [visible,setVisible]=useState(false)
 const [busy,setBusy]=useState(false)
 const [error,setError]=useState('')
 const [userId,setUserId]=useState('')
 const isSpain=getCurrentProgram().id==='kineo-es'
 useEffect(()=>{
  if(location.pathname!=='/')return
  let cancelled=false
  void (async()=>{
   const {data:{user}}=await supabase.auth.getUser()
   if(!user||cancelled)return
   setUserId(user.id)
   if(localStorage.getItem('kineo_reminder_invite_dismissed_'+user.id))return
   const {data,error}=await supabase.rpc('get_inactivity_reminder_preference_v1')
   if(!cancelled&&!error&&!data?.[0]?.opted_in)setVisible(true)
  })()
  return()=>{cancelled=true}
 },[location.pathname])
 function dismiss(){localStorage.setItem('kineo_reminder_invite_dismissed_'+userId,'1');setVisible(false)}
 async function accept(){
  setBusy(true);setError('')
  const {error}=await supabase.rpc('set_inactivity_reminder_preference_v1',{p_opted_in:true})
  if(error){setError(isSpain?'No se pudo guardar. Inténtalo de nuevo.':'Impossible d’enregistrer ce choix. Réessaie.');setBusy(false);return}
  dismiss();setBusy(false)
 }
 if(!visible||location.pathname!=='/')return null
 return <section className="reminder-invite" aria-label={isSpain?'Invitación a recordatorios':'Invitation aux rappels'}>
  <div><strong>{isSpain?'📚 ¿Seguimos repasando?':'📚 Gardons le rythme !'}</strong><p>{isSpain?'Recibe un correo tras 48 h sin actividad, como máximo uno cada 7 días. Es opcional y puedes desactivarlo en tu perfil.':'Reçois un email après 48 h sans activité, au maximum un tous les 7 jours. C’est facultatif et désactivable depuis ton profil.'}</p>{error&&<p role="alert">{error}</p>}</div>
  <div className="reminder-invite-actions"><button type="button" className="primary-button" disabled={busy} onClick={()=>void accept()}>{busy?'…':isSpain?'Sí, quiero recordatorios':'Oui, activer les rappels'}</button><button type="button" className="secondary-button" disabled={busy} onClick={dismiss}>{isSpain?'Ahora no':'Pas maintenant'}</button></div>
 </section>
}
