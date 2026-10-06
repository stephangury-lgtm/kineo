import { useEffect,useMemo,useState,type MouseEvent } from 'react'
import { Link } from 'react-router-dom'
import { getVisualReviewQueue,setVisualReview,setVisualTarget,type ReviewQuestion,type ReviewQueue,type VisualReview } from '../services/adminApi'
import './AdminPage.css'
import './VisualAdminPage.css'

const reviewFields:Array<{key:keyof Pick<VisualReview,'anatomy_ok'|'mobile_ok'|'target_ok'|'source_ok'>;label:string;hint:string}>=[
 {key:'anatomy_ok',label:'Anatomie claire',hint:'La région et la structure sont immédiatement reconnaissables.'},
 {key:'mobile_ok',label:'Lisible sur mobile',hint:'Le schéma reste exploitable sur téléphone.'},
 {key:'target_ok',label:'Zone juste',hint:'La cible correspond réellement à la structure demandée.'},
 {key:'source_ok',label:'Conforme au CM',hint:'Le visuel et la question correspondent à la source indiquée.'},
]
function normalizedReview(item:ReviewQuestion){return{anatomy_ok:Boolean(item.visual_review?.anatomy_ok),mobile_ok:Boolean(item.visual_review?.mobile_ok),target_ok:Boolean(item.visual_review?.target_ok),source_ok:Boolean(item.visual_review?.source_ok)}}

export default function VisualReviewerPage(){
 const [queue,setQueue]=useState<ReviewQueue|null>(null)
 const [busy,setBusy]=useState<string|null>(null)
 const [error,setError]=useState<string|null>(null)
 const [region,setRegion]=useState('Toutes')
 const [selectedLabel,setSelectedLabel]=useState<Record<string,number>>({})
 async function load(){setError(null);try{setQueue(await getVisualReviewQueue())}catch(e){setError(e instanceof Error?e.message:'Impossible de charger les visuels.')}}
 useEffect(()=>{void load()},[])
 const visuals=queue?.questions??[]
 const regions=useMemo(()=>['Toutes',...Array.from(new Set(visuals.map(v=>v.chapter_name)))],[visuals])
 const visible=useMemo(()=>region==='Toutes'?visuals:visuals.filter(v=>v.chapter_name===region),[visuals,region])
 const approved=visuals.filter(v=>v.visual_approved).length
 async function toggle(item:ReviewQuestion,key:keyof ReturnType<typeof normalizedReview>){setBusy(item.id);try{const current=normalizedReview(item);await setVisualReview(item.id,{...current,[key]:!current[key]});await load()}catch(e){setError(e instanceof Error?e.message:'Impossible d’enregistrer la validation.')}finally{setBusy(null)}}
 async function calibrate(item:ReviewQuestion,event:MouseEvent<HTMLDivElement>){if(!item.image_url||busy===item.id)return;const rect=event.currentTarget.getBoundingClientRect();const x=Math.max(0,Math.min(100,((event.clientX-rect.left)/rect.width)*100));const y=Math.max(0,Math.min(100,((event.clientY-rect.top)/rect.height)*100));const targetIndex=item.type==='image'?(selectedLabel[item.id]??0):null;setBusy(item.id);try{await setVisualTarget(item.id,x,y,targetIndex);await load()}catch(e){setError(e instanceof Error?e.message:'Impossible de déplacer la cible.')}finally{setBusy(null)}}
 if(!queue&&!error)return <section className="card"><p>Chargement de la relecture anatomique…</p></section>
 if(error&&!queue)return <section className="card"><h1>Accès indisponible</h1><p>{error}</p><Link className="secondary-button" to="/">Retour</Link></section>
 return <div className="stack admin-stack">
  <section className="hero-card"><div className="hero-copy"><span className="hero-kicker">Relecture anatomique</span><h1>Validation des 64 exercices</h1><p>Vérifie chaque visuel sur mobile, l’anatomie, la zone cible et la conformité à la source. Les exercices restent hors du parcours étudiant tant qu’ils ne sont pas publiés par un administrateur.</p><Link className="text-link" to="/">← Retour à l’application</Link></div><div className="hero-orbit"><span>🦴</span></div></section>
  <section className="card"><div className="section-heading"><div><p className="eyebrow">Progression</p><h2>{approved}/{visuals.length} visuels validés 4/4</h2></div><span className={approved===visuals.length?'admin-ok':'admin-alert'}>{visuals.length-approved} restant{visuals.length-approved>1?'s':''}</span></div><div className="admin-filters visual-region-filters">{regions.map(value=><button key={value} className={region===value?'active':''} onClick={()=>setRegion(value)}>{value}</button>)}</div>{error&&<p className="feedback-error">{error}</p>}
   <div className="visual-admin-list">{visible.map(item=>{const review=normalizedReview(item);const count=Object.values(review).filter(Boolean).length;const activeLabel=selectedLabel[item.id]??0;return <article className="review-item visual-review-card" key={item.id}><div className="review-head"><div><span className="review-type">{item.type==='hotspot'?'Repérage':'Étiquetage'}</span><strong>K{item.year_number} · {item.chapter_name}</strong></div><span className={item.visual_approved?'admin-ok':'admin-alert'}>{item.visual_approved?'4/4 · validé':`${count}/4`}</span></div><h3>{item.question_text}</h3><p className="review-path">{item.lesson_title}</p>{item.type==='image'&&Boolean(item.label_targets?.length)&&<div className="visual-review-targets calibration-targets">{item.label_targets?.map((target,index)=><button type="button" className={activeLabel===index?'selected':''} key={target.key??index} onClick={()=>setSelectedLabel(current=>({...current,[item.id]:index}))}><strong>{index+1}</strong> {target.label??target.key??'Étiquette'}</button>)}</div>}{item.image_url?<div className="visual-review-image calibratable" onClick={(event)=>void calibrate(item,event)}><img src={item.image_url} alt="Schéma anatomique à valider"/>{item.type==='hotspot'&&item.hotspot&&<span className="visual-review-zone" style={{left:`${item.hotspot.x}%`,top:`${item.hotspot.y}%`,width:`${Number(item.hotspot.radius??8)*2}%`,aspectRatio:'1'}}/>}{item.type==='image'&&(item.label_targets??[]).map((target,index)=><span className={`visual-review-label ${activeLabel===index?'active':''}`} key={target.key??index} style={{left:`${target.x}%`,top:`${target.y}%`}}>{index+1}</span>)}</div>:<p className="feedback-error">Image absente.</p>}<p className="visual-calibration-hint">Touchez l’image uniquement si la cible doit être recalée.</p><div className="visual-checklist">{reviewFields.map(field=><button type="button" key={field.key} className={`visual-check ${review[field.key]?'checked':''}`} disabled={busy===item.id} onClick={()=>void toggle(item,field.key)}><span className="visual-check-box">{review[field.key]?'✓':''}</span><span><strong>{field.label}</strong><small>{field.hint}</small></span></button>)}</div><div className="review-source"><strong>📚 {item.source_title??'Source absente'}</strong><span>{item.source_page?`Page ${item.source_page}`:'Page non renseignée'}</span>{item.source_excerpt&&<blockquote>{item.source_excerpt}</blockquote>}</div></article>})}</div>
  </section>
 </div>
}
