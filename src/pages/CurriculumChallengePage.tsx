import { useEffect,useState } from 'react'
import { Link,useParams } from 'react-router-dom'
import { getCurriculumFriendChallengeQuestions,submitCurriculumFriendChallengeAnswer,type CurriculumChallengeAnswerResult,type CurriculumChallengeQuestion } from '../services/challengeApi'

export default function CurriculumChallengePage(){
 const {challengeId}=useParams()
 const [questions,setQuestions]=useState<CurriculumChallengeQuestion[]>([])
 const [index,setIndex]=useState(0)
 const [selected,setSelected]=useState<string|null>(null)
 const [result,setResult]=useState<CurriculumChallengeAnswerResult|null>(null)
 const [loading,setLoading]=useState(true)
 const [busy,setBusy]=useState(false)
 const [error,setError]=useState<string|null>(null)

 useEffect(()=>{
  if(!challengeId){setError('Défi introuvable.');setLoading(false);return}
  getCurriculumFriendChallengeQuestions(challengeId).then(setQuestions).catch((e:Error)=>setError(e.message)).finally(()=>setLoading(false))
 },[challengeId])

 if(loading)return<section className="card skeleton-card"><p>Préparation du défi…</p></section>
 if(error)return<div className="stack"><section className="card"><h1>Défi indisponible</h1><p>{error}</p></section><Link className="secondary-button" to="/amis">Retour aux amis</Link></div>
 if(questions.length===0)return<div className="stack"><section className="hero-card"><div className="hero-copy"><span className="hero-kicker">Défi terminé</span><h1>Ton passage est déjà enregistré ✓</h1><p>Ton score est conservé. Le résultat final apparaîtra dès que ton ami aura joué.</p></div><div className="hero-orbit"><span>⚔️</span></div></section><Link className="primary-button" to="/amis">Voir mes défis</Link></div>

 const question=questions[index]
 const finished=!question

 async function validate(){
  if(!challengeId||!question||!selected||busy)return
  setBusy(true);setError(null)
  try{setResult(await submitCurriculumFriendChallengeAnswer(challengeId,question.id,selected))}
  catch(e){setError(e instanceof Error?e.message:'Impossible de valider la réponse.')}
  finally{setBusy(false)}
 }

 function next(){setSelected(null);setResult(null);setIndex(v=>v+1)}

 if(finished){
  const final=result
  return <div className="stack"><section className="hero-card"><div className="hero-copy"><span className="hero-kicker">Défi terminé</span><h1>{final?.score!=null?`${final.score}%`:'Score enregistré'} ⚔️</h1><p>{final?.challenge_completed?'Les deux participants ont joué : le résultat final est disponible dans Amis & défis.':'Ton score est enregistré. Le résultat final apparaîtra lorsque ton ami aura terminé.'}</p></div><div className="hero-orbit"><span>🏁</span></div></section><Link className="primary-button" to="/amis">Voir le résultat</Link></div>
 }

 return <div className="stack">
  <section className="card"><div className="section-heading"><div><p className="eyebrow">Défi entre amis</p><h1>Question {Math.min(10,result?.answered??index+1)} / 10</h1></div><strong>⚔️</strong></div><div className="progress-track"><div className="progress-fill" style={{width:`${Math.min(100,((result?.answered??index)/10)*100)}%`}}/></div></section>
  <section className="card"><h2>{question.question_text}</h2><div className="answer-options" style={{marginTop:16}}>{question.options.map(option=>{const chosen=selected===option.text;const correct=result&&option.text===result.correct_answer;const wrong=result&&chosen&&!result.correct;return <button type="button" key={option.text} className={`answer-option ${chosen?'selected':''} ${correct?'correct':''} ${wrong?'wrong':''}`} onClick={()=>!result&&setSelected(option.text)} disabled={Boolean(result)||busy}><span>{option.text}</span></button>})}</div>{error&&<p className="feedback" style={{marginTop:12}}>{error}</p>}{result?<div className={`feedback-card ${result.correct?'success':''}`} style={{marginTop:16}}><strong>{result.correct?'Bonne réponse ✓':'Réponse incorrecte'}</strong>{!result.correct&&result.correct_answer&&<p>Bonne réponse : {result.correct_answer}</p>}</div>:null}<div style={{display:'flex',gap:10,justifyContent:'flex-end',marginTop:18}}>{!result?<button className="primary-button" type="button" disabled={!selected||busy} onClick={()=>void validate()}>{busy?'Validation…':'Valider'}</button>:<button className="primary-button" type="button" onClick={next}>{result.completed_my_run?'Terminer':'Question suivante'}</button>}</div></section>
 </div>
}
