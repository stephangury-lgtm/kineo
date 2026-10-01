import { FormEvent,useState } from 'react'
import { submitFeedback,type FeedbackKind } from '../services/feedbackApi'
import './FeedbackButton.css'

const kinds:Array<{value:FeedbackKind;label:string;icon:string}>=[
 {value:'bug',label:'Bug',icon:'🐞'},
 {value:'content',label:'Contenu',icon:'📚'},
 {value:'suggestion',label:'Suggestion',icon:'💡'},
]

export default function FeedbackButton(){
 const [open,setOpen]=useState(false)
 const [kind,setKind]=useState<FeedbackKind>('bug')
 const [message,setMessage]=useState('')
 const [busy,setBusy]=useState(false)
 const [error,setError]=useState<string|null>(null)
 const [sent,setSent]=useState(false)
 async function submit(event:FormEvent){
  event.preventDefault();if(message.trim().length<10)return
  setBusy(true);setError(null)
  try{await submitFeedback(kind,message.trim(),`${window.location.pathname}${window.location.search}`);setSent(true);setMessage('')}
  catch(e){setError(e instanceof Error?e.message:'Impossible d’envoyer le signalement.')}
  finally{setBusy(false)}
 }
 function close(){setOpen(false);setError(null);setSent(false)}
 return <>
  <button className="feedback-fab" type="button" onClick={()=>setOpen(true)} aria-label="Signaler un problème ou faire une suggestion">!</button>
  {open&&<div className="feedback-overlay" role="presentation" onMouseDown={event=>{if(event.target===event.currentTarget)close()}}>
   <section className="feedback-dialog" role="dialog" aria-modal="true" aria-labelledby="feedback-title">
    <div className="feedback-heading"><div><p className="eyebrow">Aide à améliorer Kineo</p><h2 id="feedback-title">Signaler quelque chose</h2></div><button className="feedback-close" type="button" onClick={close} aria-label="Fermer">×</button></div>
    {sent?<div className="feedback-success"><span>✓</span><strong>Merci, retour enregistré.</strong><p>La page concernée a été ajoutée automatiquement au signalement.</p><button className="primary-button wide" type="button" onClick={close}>Fermer</button></div>:<form onSubmit={submit} className="feedback-form">
     <div className="feedback-kinds">{kinds.map(item=><button key={item.value} type="button" className={kind===item.value?'feedback-kind active':'feedback-kind'} onClick={()=>setKind(item.value)}><span>{item.icon}</span>{item.label}</button>)}</div>
     <label htmlFor="feedback-message">Que s’est-il passé ?</label>
     <textarea id="feedback-message" rows={5} maxLength={2000} value={message} onChange={event=>setMessage(event.target.value)} placeholder={kind==='content'?'Ex. : la correction de cette question ne correspond pas au CM…':kind==='bug'?'Ex. : le bouton ne répond pas après validation…':'Décris ton idée en quelques mots…'}/>
     <div className="feedback-meta"><span>{message.length}/2000</span><span>Page jointe automatiquement</span></div>
     {error&&<p className="feedback-error">{error}</p>}
     <button className="primary-button wide" type="submit" disabled={busy||message.trim().length<10}>{busy?'Envoi…':'Envoyer le retour'}</button>
    </form>}
   </section>
  </div>}
 </>
}
