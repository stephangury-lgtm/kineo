import { useEffect, useRef, useState } from 'react'
import type { FriendChallenge } from '../services/challengeApi'
import { readDuelMessages, sendDuelMessage, type DuelConversationData } from '../services/duelMessageApi'
import { getDuelMessagePresets } from '../services/duelMessagePresets'
import { subscribeToNotificationChanges } from '../services/notificationApi'
import './DuelConversation.css'

type Props = {duel:FriendChallenge; programId:string; isSpain:boolean; canRematch:boolean; onClose:()=>void; onRematch:()=>void}
export default function DuelConversation({duel,programId,isSpain,canRematch,onClose,onRematch}:Props) {
 const dialog=useRef<HTMLDialogElement>(null)
 const log=useRef<HTMLDivElement>(null)
 const lastVisibleMessage=useRef<string|null>(null)
 const request=useRef<{body:string;id:string}|null>(null)
 const mounted=useRef(true)
 const refreshing=useRef(false)
 const sending=useRef(false)
 const [data,setData]=useState<DuelConversationData|null>(null)
 const [draft,setDraft]=useState('')
 const [busy,setBusy]=useState(false)
 const [error,setError]=useState<string|null>(null)
 const name=duel.opponent.first_name||duel.opponent.username
 const t=(fr:string,es:string)=>isSpain?es:fr
 async function refresh() {
  if(refreshing.current)return
  refreshing.current=true
  try{const value=await readDuelMessages(duel.id,programId);if(mounted.current)setData(value)}
  finally{refreshing.current=false}
 }
 useEffect(()=>{
  mounted.current=true
  const modal=dialog.current;modal?.showModal()
  const update=()=>{if(document.visibilityState==='visible')void refresh().catch(()=>undefined)}
  void refresh().catch((e:Error)=>{if(mounted.current)setError(e.message)})
  const unsubscribe=subscribeToNotificationChanges(update)
  const timer=window.setInterval(update,15000)
  window.addEventListener('focus',update);document.addEventListener('visibilitychange',update)
  return()=>{mounted.current=false;modal?.close();unsubscribe();window.clearInterval(timer);window.removeEventListener('focus',update);document.removeEventListener('visibilitychange',update)}
 },[duel.id,programId])
 useEffect(()=>{
  const node=log.current;const last=data?.messages.at(-1)
  if(node&&last&&last.id!==lastVisibleMessage.current){
   if(!lastVisibleMessage.current||last.is_mine||node.scrollHeight-node.clientHeight-node.scrollTop<180)node.scrollTop=node.scrollHeight
   lastVisibleMessage.current=last.id
  }
 },[data])
 async function send(rematch=false) {
  if(sending.current||!data?.can_send)return
  const body=draft.trim().replace(/\s+/g,' ')
  if(!body){if(rematch&&canRematch)onRematch();return}
  sending.current=true;setBusy(true);setError(null)
  if(request.current?.body!==body)request.current={body,id:crypto.randomUUID()}
  try{
   await sendDuelMessage(duel.id,programId,body,request.current.id)
   // An acknowledged send must never be retried because the subsequent refresh failed.
   request.current=null
   if(!mounted.current)return
   setDraft('')
   window.dispatchEvent(new Event('kineo-notifications-updated'))
   if(rematch&&canRematch){onRematch();return}
   await refresh().catch(()=>{if(mounted.current)setError(t('Message envoyé. Réouvre la discussion pour actualiser les messages.','Mensaje enviado. Vuelve a abrir la conversación para actualizarla.'))})
  }catch(e){if(mounted.current)setError(e instanceof Error?e.message:t('Envoi impossible. Réessaie.','No se pudo enviar. Inténtalo de nuevo.'))}
  finally{sending.current=false;if(mounted.current)setBusy(false)}
 }
 return <dialog ref={dialog} className="duel-conversation" aria-labelledby="duel-conversation-title" onCancel={e=>{if(busy){e.preventDefault();return}onClose()}}>
  <header><div><p className="eyebrow">{t('Après le duel','Después del duelo')}</p><h2 id="duel-conversation-title">💬 {name}</h2></div><button type="button" className="secondary-button compact-button" disabled={busy} onClick={onClose}>{t('Fermer','Cerrar')}</button></header>
  <p>{t('Une petite taquinerie, un encouragement… on progresse ensemble. Reste sympa !','Una broma amable, unas palabras de ánimo… aprendemos juntos. ¡Con respeto!')}</p>
  <p className="field-hint">{t('Ton score','Tu resultado')} : {duel.direction==='sent'?duel.challenger_score:duel.challenged_score} % · {name} : {duel.direction==='sent'?duel.challenged_score:duel.challenger_score} %</p>
  <div ref={log} className="duel-message-list" role="log" aria-label={t('Messages du duel','Mensajes del duelo')} aria-live="polite">
   {!data&&!error&&<p>{t('Chargement…','Cargando…')}</p>}
   {data?.messages.length===0&&<p>{t('Le duel est fini, la bonne humeur continue. À toi le premier mot !','El duelo ha terminado, el buen humor continúa. ¡Di la primera palabra!')}</p>}
   {data?.messages.length===100&&<p>{t('Les 100 derniers messages','Los últimos 100 mensajes')}</p>}
   {data?.messages.map(m=><article key={m.id} className={`duel-message${m.is_mine?' is-mine':''}`}><strong>{m.is_mine?t('Toi','Tú'):m.sender_name}</strong><p>{m.body}</p><time dateTime={m.created_at}>{new Date(m.created_at).toLocaleString(isSpain?'es-ES':'fr-FR',{day:'numeric',month:'short',hour:'2-digit',minute:'2-digit'})}</time></article>)}
  </div>
  {data?.can_send&&<form onSubmit={e=>{e.preventDefault();void send()}}>
   <div className="duel-presets" aria-label={t('Idées de petits mots','Ideas para tu mensaje')}>{getDuelMessagePresets(duel,isSpain).map(text=><button type="button" className="secondary-button" key={text} disabled={busy} onClick={()=>setDraft(text)}>{text}</button>)}</div>
   <label htmlFor="duel-message-draft">{t('Ton message','Tu mensaje')}</label>
   <textarea id="duel-message-draft" value={draft} onChange={e=>setDraft(e.target.value)} maxLength={240} rows={3} disabled={busy}/>
   <p className="field-hint">{draft.length}/240 · {t('Choisir une phrase prépare le brouillon. Tu décides quand l’envoyer.','Elegir una frase prepara el borrador. Tú decides cuándo enviarlo.')}</p>
   <button className="primary-button" disabled={busy||!draft.trim()} type="submit">{busy?'…':t('Envoyer','Enviar')}</button>
  </form>}
  {data&&!data.can_send&&<p>{t('Vous devez encore être amis pour envoyer de nouveaux messages.','Debéis seguir siendo amigos para enviar nuevos mensajes.')}</p>}
  {error&&<p role="alert">{error}</p>}
  <footer><button className="secondary-button" disabled={busy||!canRematch||!data?.can_send} onClick={()=>{if(draft.trim())void send(true);else onRematch()}}>{draft.trim()?t('Envoyer et relancer','Enviar y pedir revancha'):t('Lancer la revanche','Pedir revancha')}</button>{!canRematch&&<p className="field-hint">{t('La revanche nécessite un ami du même niveau et aucun défi en cours entre vous.','Para la revancha: un amigo del mismo nivel y ningún reto en curso entre vosotros.')}</p>}</footer>
 </dialog>
}
