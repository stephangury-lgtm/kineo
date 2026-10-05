import { useEffect,useState } from 'react'
import { Link,useParams } from 'react-router-dom'
import { getCurrentProgram } from '../curriculum/programs'
import { getCurriculumFriendChallengeQuestions,submitCurriculumFriendChallengeAnswer,type CurriculumChallengeAnswerResult,type CurriculumChallengeQuestion } from '../services/challengeApi'

export default function CurriculumChallengePage(){
 const {challengeId}=useParams()
 const program=getCurrentProgram()
 const [questions,setQuestions]=useState<CurriculumChallengeQuestion[]>([])
 const [index,setIndex]=useState(0)
 const [selected,setSelected]=useState<string|null>(null)
 const [result,setResult]=useState<CurriculumChallengeAnswerResult|null>(null)
 const [finalResult,setFinalResult]=useState<CurriculumChallengeAnswerResult|null>(null)
 const [loading,setLoading]=useState(true)
 const [busy,setBusy]=useState(false)
 const [error,setError]=useState<string|null>(null)

 useEffect(()=>{
  if(!challengeId){setError('Défi introuvable.');setLoading(false);return}
  getCurriculumFriendChallengeQuestions(challengeId).then(setQuestions).catch((e:Error)=>setError(e.message)).finally(()=>setLoading(false))
 },[challengeId])

 if(loading)return<section className="card skeleton-card"><p>Préparation du défi {program.shortName}…</p></section>
 if(error)return<div className="stack"><section className="card"><p className="eyebrow">{program.shortName}</p><h1>Défi indisponible</h1><p>{error}</p></section><Link className="secondary-button" to="/amis">Retour aux amis</Link></div>
 if(questions.length===0)return<div className="stack"><section className="hero-card"><div className="hero-copy"><span className="hero-kicker">Défi terminé · {program.shortName}</span><h1>Ton passage est déjà enregistré ✓</h1><p>Ton score est conservé dans ce cursus. Le résultat final apparaîtra dès que ton ami aura joué.</p></div><div className="hero-orbit"><span>⚔️</span></div></section><Link className="primary-button" to="/amis">Voir mes défis</Link></div>

 const question=questions[index]
 const finished=!question

 async function validate(){
  if(!challengeId||!question||!selected||busy)return
  setBusy(true);setError(null)
  try{const answer=await submitCurriculumFriendChallengeAnswer(challengeId,question.id,selected);setResult(answer);if(answer.completed_my_run)setFinalResult(answer)}
  catch(e){setError(e instanceof Error?e.message:'Impossible de valider la réponse.')}
  finally{setBusy(false)}
 }

 function next(){setSelected(null);setResult(null);setIndex(v=>v+1)}

 if(finished){
  return <div className="stack"><section className="hero-card"><div className="hero-copy"><span className="hero-kicker">Défi terminé · {program.shortName}</span><h1>{finalResult?.score!=null?`${finalResult.score}%`:'Score enregistré'} ⚔️</h1><p>{finalResult?.challenge_completed?'Les deux participants ont joué : le résultat final est disponible dans Amis & défis.':'Ton score est enregistré dans ce cursus. Le résultat final apparaîtra lorsque ton ami aura terminé.'}</p></div><div className="hero-orbit"><span>🏁</span></div></section><Link className="primary-button" to="/amis">Voir le résultat</Link></div>
 }

 return <div className="stack">
  <section className="card"><div className="section-heading"><div><p className="eyebrow">Défi entre amis · {program.shortName}</p><h1>Question {Math.min(10,result?.answered??index+1)} / 10</h1></div><strong>⚔️</strong></div><div className="progress-track" aria-label={`Progression ${Math.min(10,result?.answered??index)} sur 10`}><div className="progress-fill" style={{width:`${Math.min(100,((result?.answered??index)/10)*100)}%`}}/></div></section>
  <section className="card quiz-card"><h2>{question.question_text}</h2><div className="answers">{question.options.map(option=>{const chosen=selected===option.text;const correct=Boolean(result&&option.text===result.correct_answer);const incorrect=Boolean(result&&chosen&&!result.correct);return <button type="button" key={option.text} className={`answer ${chosen?'selected':''} ${correct?'correct':''} ${incorrect?'incorrect':''}`} onClick={()=>!result&&setSelected(option.text)} disabled={Boolean(result)||busy}>{option.text}</button>})}</div>{error&&<p className="feedback" role="alert">{error}</p>}{result?<div className={`result-box ${result.correct?'success':'retry'}`} aria-live="polite"><strong>{result.correct?'Bonne réponse ✓':'Réponse incorrecte'}</strong>{!result.correct&&result.correct_answer&&<p>Bonne réponse : {result.correct_answer}</p>}</div>:null}<div className="quiz-actions">{!result?<button className="primary-button" type="button" disabled={!selected||busy} onClick={()=>void validate()}>{busy?'Validation…':'Valider'}</button>:<button className="primary-button" type="button" onClick={next}>{result.completed_my_run?'Terminer':'Question suivante'}</button>}</div></section>
 </div>
}
