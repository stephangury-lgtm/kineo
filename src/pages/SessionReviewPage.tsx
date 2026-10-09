import { useEffect, useMemo, useState } from 'react'
import { Link, useParams } from 'react-router-dom'
import { getRevisionSessionReviewV2, type SessionReviewItem } from '../services/kineoApi'
import './SessionReviewPage.css'

function secondsLabel(ms:number|null){if(!ms)return '—';const s=Math.round(ms/1000);return s<60?`${s}s`:`${Math.floor(s/60)} min ${s%60}s`}

export default function SessionReviewPage(){
  const {sessionId}=useParams()
  const [items,setItems]=useState<SessionReviewItem[]>([])
  const [loading,setLoading]=useState(true)
  const [filter,setFilter]=useState<'all'|'wrong'|'correct'>('all')
  const [message,setMessage]=useState<string|null>(null)

  useEffect(()=>{if(!sessionId)return;getRevisionSessionReviewV2(sessionId).then(setItems).catch((e:Error)=>setMessage(e.message)).finally(()=>setLoading(false))},[sessionId])
  const wrong=useMemo(()=>items.filter(item=>!item.is_correct),[items])
  const visibleItems=filter==='wrong'?wrong:filter==='correct'?items.filter(item=>item.is_correct):items
  const score=items.length?Math.round(((items.length-wrong.length)/items.length)*100):0


  if(loading)return <section className="card skeleton-card"><p>Analyse de la session…</p></section>
  if(message&&items.length===0)return <section className="card"><h1>Session indisponible</h1><p>{message}</p><Link className="secondary-button" to="/stats">Retour aux statistiques</Link></section>

  return <div className="stack session-review-page">
    <section className="stats-hero"><div><p className="eyebrow light">Correction détaillée</p><h1>Revoir ma session</h1><p>Comprends tes erreurs, retrouve la réponse attendue et rejoue uniquement ce qui mérite encore du travail.</p></div><div className="stats-hero-score"><span>Score</span><strong>{score}%</strong></div></section>
    <section className="review-summary-grid"><article className="card"><span>✅ Correctes</span><strong>{items.length-wrong.length}</strong></article><article className="card"><span>💡 À revoir</span><strong>{wrong.length}</strong></article><article className="card"><span>❓ Total</span><strong>{items.length}</strong></article></section>
    {wrong.length>0&&<section className="card review-retry-card"><div><p className="eyebrow">Révision ciblée</p><h2>Revoir les notions avant de les réviser</h2><p>Relis les corrections maintenant. Les erreurs seront retravaillées lors d’une prochaine session de révision, après un délai de mémorisation.</p></div><Link className="secondary-button" to="/revision">Mes révisions</Link></section>}
    <div className="review-filters" role="group" aria-label="Filtrer les réponses"><button type="button" className={filter==='all'?'primary-button':'secondary-button'} aria-pressed={filter==='all'} onClick={()=>setFilter('all')}>Toutes ({items.length})</button><button type="button" className={filter==='wrong'?'primary-button':'secondary-button'} aria-pressed={filter==='wrong'} onClick={()=>setFilter('wrong')}>À revoir ({wrong.length})</button><button type="button" className={filter==='correct'?'primary-button':'secondary-button'} aria-pressed={filter==='correct'} onClick={()=>setFilter('correct')}>Correctes ({items.length-wrong.length})</button></div>
    <section className="review-list">{visibleItems.map(item=><article key={item.question_id} className={`card review-question ${item.is_correct?'is-correct':'is-wrong'}`}><div className="review-question-head"><span className="review-status">{item.is_correct?'✓':'!'}</span><div><p className="eyebrow">Question {item.display_order} · {item.subject_name}</p><h2>{item.question_text}</h2></div><span className="review-time">{secondsLabel(item.response_time_ms)}</span></div>{item.image_url&&<img className="question-image" src={item.image_url} alt="Illustration de la question"/>}<div className="review-answer-grid"><div><span>Ta réponse</span><strong>{item.user_answer_display||'Réponse enregistrée'}</strong></div><div><span>Réponse attendue</span><strong>{item.correct_answer_display||'Voir l’explication'}</strong></div></div>{item.explanation&&<div className="review-explanation"><strong>Pourquoi ?</strong><p>{item.explanation}</p></div>}{item.source_title&&<p className="review-source">📚 {item.source_title}{item.source_page?` · p. ${item.source_page}`:''}</p>}</article>)}</section>
    {message&&<section className="card feedback-card"><p className="feedback">{message}</p></section>}
    <div className="review-footer"><Link className="secondary-button" to="/stats">Retour aux statistiques</Link><Link className="text-link" to="/">Accueil</Link></div>
  </div>
}
