import { useEffect,useMemo,useState,type MouseEvent } from 'react'
import { Link } from 'react-router-dom'
import { getContentReviewQueue,setContentReviewStatus,setVisualReview,setVisualTarget,type ReviewQuestion,type ReviewQueue,type VisualReview } from '../services/adminApi'
import './AdminPage.css'
import './VisualAdminPage.css'

const typeLabel:Record<string,string>={hotspot:'Repérage anatomique',image:'Placement d’étiquettes'}
const reviewFields:Array<{key:keyof Pick<VisualReview,'anatomy_ok'|'mobile_ok'|'target_ok'|'source_ok'>;label:string;hint:string}>=[
 {key:'anatomy_ok',label:'Anatomie claire',hint:'La région et la structure sont immédiatement reconnaissables.'},
 {key:'mobile_ok',label:'Lisible sur mobile',hint:'Le schéma reste exploitable sans zoom ni texte minuscule.'},
 {key:'target_ok',label:'Zone juste',hint:'La cible ou les étiquettes correspondent réellement à la structure.'},
 {key:'source_ok',label:'Conforme au CM',hint:'Le visuel et la question correspondent à la source et à la page indiquées.'},
]

function normalizedReview(item:ReviewQuestion){return{anatomy_ok:Boolean(item.visual_review?.anatomy_ok),mobile_ok:Boolean(item.visual_review?.mobile_ok),target_ok:Boolean(item.visual_review?.target_ok),source_ok:Boolean(item.visual_review?.source_ok)}}

export default function VisualAdminPage(){
 const [queue,setQueue]=useState<ReviewQueue|null>(null)
 const [busy,setBusy]=useState<string|null>(null)
 const [error,setError]=useState<string|null>(null)
 const [region,setRegion]=useState('Toutes')
 const [selectedLabel,setSelectedLabel]=useState<Record<string,number>>({})
 async function load(){setError(null);try{setQueue(await getContentReviewQueue())}catch(e){setError(e instanceof Error?e.message:'Impossible de charger les visuels.')}}
 useEffect(()=>{void load()},[])
 const visuals=useMemo(()=>queue?.questions.filter(q=>q.type==='hotspot'||q.type==='image')??[],[queue])
 const regions=useMemo(()=>['Toutes',...Array.from(new Set(visuals.map(v=>v.chapter_name)))],[visuals])
 const visibleVisuals=useMemo(()=>region==='Toutes'?visuals:visuals.filter(v=>v.chapter_name===region),[visuals,region])
 async function toggleReview(item:ReviewQuestion,key:keyof ReturnType<typeof normalizedReview>){setBusy(item.id);setError(null);try{const current=normalizedReview(item);await setVisualReview(item.id,{...current,[key]:!current[key]});await load()}catch(e){setError(e instanceof Error?e.message:'Impossible de mettre à jour le contrôle visuel.')}finally{setBusy(null)}}
 async function changeStatus(item:ReviewQuestion,status:'review'|'validated'|'published'){setBusy(item.id);setError(null);try{await setContentReviewStatus(item.id,status);await load()}catch(e){setError(e instanceof Error?e.message:'Impossible de modifier le statut.')}finally{setBusy(null)}}
 async function calibrate(item:ReviewQuestion,event:MouseEvent<HTMLDivElement>){
  if(!item.image_url||busy===item.id)return
  const rect=event.currentTarget.getBoundingClientRect()
  const x=Math.max(0,Math.min(100,((event.clientX-rect.left)/rect.width)*100))
  const y=Math.max(0,Math.min(100,((event.clientY-rect.top)/rect.height)*100))
  const targetIndex=item.type==='image'?(selectedLabel[item.id]??0):null
  setBusy(item.id);setError(null)
  try{await setVisualTarget(item.id,x,y,targetIndex);await load()}catch(e){setError(e instanceof Error?e.message:'Impossible de recalibrer la cible.')}finally{setBusy(null)}
 }
 if(!queue&&!error)return <section className="card"><p>Chargement des exercices visuels…</p></section>
 if(error&&!queue)return <section className="card"><p className="eyebrow">Administration</p><h1>Validation visuelle indisponible</h1><p>{error}</p><Link className="secondary-button" to="/admin">Retour à l’administration</Link></section>
 return <div className="stack admin-stack">
  <section className="hero-card"><div className="hero-copy"><span className="hero-kicker">Administration · Visuels</span><h1>Contrôle anatomique</h1><p>Les visuels en quarantaine restent hors du parcours étudiant mais sont désormais contrôlables ici avant réactivation.</p><Link className="text-link" to="/admin">← Centre admin</Link></div><div className="hero-orbit"><span>🦴</span></div></section>
  <section className="card"><div className="section-heading"><div><p className="eyebrow">File visuelle</p><h2>{visuals.length} exercice{visuals.length>1?'s':''} à suivre</h2></div><span className="admin-alert">{queue?.counts.quarantined_visual??0} en quarantaine</span></div><div className="admin-filters visual-region-filters">{regions.map(value=><button key={value} className={region===value?'active':''} onClick={()=>setRegion(value)}>{value}{value!=='Toutes'?` · ${visuals.filter(v=>v.chapter_name===value).length}`:''}</button>)}</div>{error&&<p className="feedback-error">{error}</p>}<div className="visual-admin-list">{visibleVisuals.length===0?<div className="admin-empty"><span>✓</span><strong>Aucun visuel dans ce filtre.</strong></div>:visibleVisuals.map(item=>{const review=normalizedReview(item);const reviewCount=Object.values(review).filter(Boolean).length;const activeLabel=selectedLabel[item.id]??0;const archived=item.validation_status==='archived';return <article className="review-item visual-review-card" key={item.id}><div className="review-head"><div><span className="review-type">{typeLabel[item.type]??item.type}</span><strong>K{item.year_number} · {item.chapter_name}</strong></div><span className={item.visual_approved?'admin-ok':'admin-alert'}>{archived?'Quarantaine · ':''}{item.visual_approved?'4/4 · prêt':`${reviewCount}/4 · à contrôler`}</span></div><h3>{item.question_text}</h3><p className="review-path">{item.lesson_title}{item.visual_rebuild_batch?` · Lot ${item.visual_rebuild_batch}`:''}</p>{item.type==='hotspot'?<p className="visual-calibration-hint">🎯 Clique directement au centre de la structure correcte pour déplacer la zone cible.</p>:<p className="visual-calibration-hint">🏷️ Sélectionne une étiquette ci-dessous, puis clique sur sa position correcte dans l’image.</p>}{item.type==='image'&&Boolean(item.label_targets?.length)&&<div className="visual-review-targets calibration-targets">{item.label_targets?.map((target,index)=><button type="button" className={activeLabel===index?'selected':''} key={target.key??index} onClick={()=>setSelectedLabel(current=>({...current,[item.id]:index}))}><strong>{index+1}</strong> {target.label??target.key??'Étiquette'}</button>)}</div>}{item.image_url?<div className="visual-review-image calibratable" onClick={(event)=>void calibrate(item,event)}><img src={item.image_url} alt="Schéma anatomique à valider"/>{item.type==='hotspot'&&item.hotspot&&<span className="visual-review-zone" style={{left:`${item.hotspot.x}%`,top:`${item.hotspot.y}%`,width:`${Number(item.hotspot.radius??8)*2}%`,aspectRatio:'1'}} title={item.hotspot.label??'Zone attendue'}/>} {item.type==='image'&&(item.label_targets??[]).map((target,index)=><span className={`visual-review-label ${activeLabel===index?'active':''}`} key={target.key??index} style={{left:`${target.x}%`,top:`${target.y}%`}}>{index+1}</span>)}</div>:<p className="feedback-error">Image absente.</p>}<div className="visual-checklist">{reviewFields.map(field=><button type="button" key={field.key} className={`visual-check ${review[field.key]?'checked':''}`} disabled={busy===item.id} onClick={()=>void toggleReview(item,field.key)}><span className="visual-check-box">{review[field.key]?'✓':''}</span><span><strong>{field.label}</strong><small>{field.hint}</small></span></button>)}</div><div className="review-source"><strong>📚 {item.source_title??'Source absente'}</strong><span>{item.source_page?`Page ${item.source_page}`:'Page non renseignée'}</span>{item.source_excerpt&&<blockquote>{item.source_excerpt}</blockquote>}</div><div className="admin-feedback-actions"><span>Statut : {item.validation_status}</span>{archived&&item.visual_approved&&<button className="secondary-button compact-button" disabled={busy===item.id} onClick={()=>void changeStatus(item,'review')}>Passer en revue</button>}{item.visual_approved&&item.validation_status==='review'&&<button className="secondary-button compact-button" disabled={busy===item.id} onClick={()=>void changeStatus(item,'validated')}>Valider la question</button>}{item.visual_approved&&item.validation_status==='validated'&&<button className="primary-button compact-button" disabled={busy===item.id} onClick={()=>void changeStatus(item,'published')}>Publier</button>}</div></article>})}</div></section>
 </div>
}
