import { useEffect,useState } from 'react'
import { Link,useSearchParams } from 'react-router-dom'
import { getCurrentProgram } from '../curriculum/programs'
import { getFoundationQuestions,submitFoundationAnswer,type FoundationMode,type FoundationQuestion } from '../services/foundationApi'
import type { CurriculumAnswerResult } from '../services/programCatalogApi'

export default function FoundationsPage(){
 const program=getCurrentProgram()
 const [params]=useSearchParams()
 const mode:FoundationMode=params.get('mode')==='mix'?'mix':'foundation'
 const scope=params.get('scope')
 const scopedLevel=scope==='semester'?(params.get('level')??undefined):undefined
 const scopedUnit=scope==='unit'?(params.get('unit')??undefined):undefined
 const scopeLabel=params.get('label')??''
 const sessionCount=scope==='semester'?20:scope==='unit'?15:10
 const isSpain=program.id==='kineo-es'
 const [questions,setQuestions]=useState<FoundationQuestion[]>([])
 const [started,setStarted]=useState(false)
 const [index,setIndex]=useState(0)
 const [selected,setSelected]=useState('')
 const [result,setResult]=useState<CurriculumAnswerResult|null>(null)
 const [correctCount,setCorrectCount]=useState(0)
 const [loading,setLoading]=useState(true)
 const [busy,setBusy]=useState(false)
 const [error,setError]=useState<string|null>(null)

 useEffect(()=>{
  setLoading(true);setError(null);setIndex(0);setSelected('');setResult(null);setCorrectCount(0);setStarted(false)
  getFoundationQuestions(program.id,mode,sessionCount,{levelCode:scopedLevel,unitId:scopedUnit}).then(setQuestions).catch(e=>setError(e instanceof Error?e.message:(isSpain?'Sesión no disponible.':'Session indisponible.'))).finally(()=>setLoading(false))
 },[program.id,mode,isSpain,scopedLevel,scopedUnit,sessionCount])

 if(loading)return <section className="card skeleton-card"><p>{isSpain?'Preparando tu repaso…':'Préparation de ta révision…'}</p></section>
 if(error)return <div className="stack"><section className="card"><h1>{isSpain?'Repaso no disponible':'Révision indisponible'}</h1><p>{error}</p></section><Link className="secondary-button" to="/parcours">{isSpain?'Volver':'Retour au parcours'}</Link></div>
 if(!questions.length)return <div className="stack"><section className="card"><h1>{isSpain?'Contenido en preparación':'Contenu en préparation'}</h1><p>{isSpain?'Todavía no hay suficientes preguntas validadas para este modo.':'Il n’y a pas encore assez de questions validées pour ce mode.'}</p></section><Link className="secondary-button" to="/parcours">{isSpain?'Volver':'Retour au parcours'}</Link></div>
 if(!started){const levelCodes=Array.from(new Set(questions.map(question=>question.level_code))).sort((a,b)=>a.localeCompare(b,undefined,{numeric:true}));const scopedTitle=scope==='unit'?(scopeLabel||'Révision par UE'):scope==='semester'?(scopeLabel||`Révision ${scopedLevel??''}`):null;return <div className="stack foundation-revision-page"><section className="hero-card"><div className="hero-copy"><p className="eyebrow light">{scopedTitle??(mode==='mix'?(isSpain?'Mix acumulativo':'Mix complet'):(isSpain?'Fundamentos':'Retour aux fondamentaux'))}</p><h1>{isSpain?`${sessionCount} preguntas para consolidar lo esencial`:`${sessionCount} questions pour consolider tes acquis`}</h1><p>{scope==='unit'?'Cette session mélange les notions publiées et validées de cette UE.':scope==='semester'?'Cette session mélange les notions publiées et validées de tout le semestre.':mode==='mix'?(isSpain?'Kineo mezcla tu nivel actual con todos los niveles anteriores ya desbloqueados.':'Kineo mélange ton niveau actuel avec tous les niveaux précédents déjà déverrouillés.'):(isSpain?'Kineo da prioridad a los conocimientos esenciales de los niveles que ya has estudiado.':'Kineo donne la priorité aux acquis essentiels des niveaux que tu as déjà étudiés.')}</p><p className="field-hint">{isSpain?'Niveles incluidos':'Niveaux inclus'} : <strong>{levelCodes.join(' · ')}</strong></p><button className="primary-button hero-action" type="button" onClick={()=>setStarted(true)}>{isSpain?'Empezar':'Commencer'}</button></div><div className="hero-orbit">🧠</div></section></div>}
 if(index>=questions.length){const percent=Math.round((correctCount/questions.length)*100);return <div className="stack"><section className="session-complete"><div className="completion-icon">{percent>=80?'🏆':percent>=60?'🎉':'💪'}</div><p className="eyebrow">{mode==='mix'?(isSpain?'Mix acumulativo':'Mix complet'):(isSpain?'Fundamentos':'Retour aux fondamentaux')}</p><h1>{percent>=80?(isSpain?'¡Excelente trabajo!':'Excellent travail !'):percent>=60?(isSpain?'¡Buen progreso!':'Belle progression !'):(isSpain?'Sigue así, estás progresando.':'Continue, tu progresses !')}</h1><div className="completion-score">{percent}%</div><p>{correctCount} / {questions.length} {isSpain?'respuestas correctas':'bonnes réponses'}.</p></section><section className="completion-grid"><article className="card"><span>✅ {isSpain?'Correctas':'Bonnes réponses'}</span><strong>{correctCount}</strong></article><article className="card"><span>❓ {isSpain?'Preguntas':'Questions'}</span><strong>{questions.length}</strong></article><article className="card"><span>🎯 {isSpain?'Puntuación':'Score'}</span><strong>{percent}%</strong></article></section><div className="completion-actions"><button className="primary-button" type="button" onClick={()=>void restart()}>{isSpain?'Repetir':'Recommencer'}</button><Link className="secondary-button" to="/parcours">{isSpain?'Volver al temario':'Retour au parcours'}</Link><Link className="secondary-button" to="/stats">{isSpain?'Ver mi progreso':'Voir mes statistiques'}</Link><Link className="text-link" to="/rewards">{isSpain?'Ver mis logros':'Voir mes récompenses'}</Link></div></div>}

 const question=questions[index]
 const isText=question.question_type==='fill_blank'
 async function validate(){
  if(!selected.trim()||busy)return
  setBusy(true);setError(null)
  try{
   const answer=await submitFoundationAnswer(question.id,{text:selected})
   setResult(answer)
   if(answer.correct)setCorrectCount(value=>value+1)
  }catch(e){setError(e instanceof Error?e.message:(isSpain?'No se pudo validar la respuesta.':'Impossible de valider la réponse.'))}
  finally{setBusy(false)}
 }
 async function restart(){
  setLoading(true);setError(null);setIndex(0);setSelected('');setResult(null);setCorrectCount(0)
  try{setQuestions(await getFoundationQuestions(program.id,mode,sessionCount,{levelCode:scopedLevel,unitId:scopedUnit}));setStarted(true)}
  catch(e){setError(e instanceof Error?e.message:(isSpain?'Sesión no disponible.':'Session indisponible.'))}
  finally{setLoading(false)}
 }
 function next(){setSelected('');setResult(null);setIndex(value=>value+1)}

 return <div className="stack foundation-revision-page">
  <section className="card"><div className="section-heading"><div><p className="eyebrow">{mode==='mix'?(isSpain?'Mix acumulativo':'Mix complet'):(isSpain?'Fundamentos':'Retour aux fondamentaux')}</p><h2>{isSpain?'Pregunta':'Question'} {index+1} {isSpain?'de':'sur'} {questions.length}</h2></div><strong>{Math.round(((index+1)/questions.length)*100)}%</strong></div><div className="progress-track"><div className="progress-fill" style={{width:`${((index+1)/questions.length)*100}%`}}/></div></section>
  <section className="card quiz-card"><p className="eyebrow">{isText?(isSpain?'Texto para completar':'Texte à compléter'):'QCM'} · {question.level_code}</p><h1>{question.question_text}</h1>{isText?<label className="text-answer-wrap"><span>{isSpain?'Tu respuesta':'Ta réponse'}</span><input className="text-answer" value={selected} onChange={event=>!result&&setSelected(event.target.value)} disabled={Boolean(result)||busy}/></label>:<div className="answers">{question.options.map(option=>{const chosen=selected===option.text;const correct=Boolean(result?.correct_answer&&option.text===result.correct_answer);const incorrect=Boolean(result&&chosen&&!result.correct);return <button type="button" key={option.text} className={`answer ${chosen?'selected':''} ${correct?'correct':''} ${incorrect?'incorrect':''}`} onClick={()=>!result&&setSelected(option.text)} disabled={Boolean(result)||busy}>{option.text}</button>})}</div>}{error&&<p className="feedback" role="alert">{error}</p>}{result&&<div className={`result-box ${result.correct?'success':'retry'}`}><strong>{result.correct?(isSpain?'Respuesta correcta ✅':'Bonne réponse ✅'):(isSpain?'Para repasar 💡':'À revoir 💡')}</strong>{!result.correct&&result.correct_answer&&<p>{isSpain?'Respuesta correcta':'Bonne réponse'} : {result.correct_answer}</p>}{question.explanation&&<p>{question.explanation}</p>}</div>}<div className="quiz-actions">{!result?<button className="primary-button wide" type="button" onClick={()=>void validate()} disabled={!selected.trim()||busy}>{busy?(isSpain?'Validando…':'Validation…'):(isSpain?'Validar mi respuesta':'Valider ma réponse')}</button>:<button className="primary-button wide" type="button" onClick={next}>{index+1===questions.length?(isSpain?'Ver mis resultados':'Voir mes résultats'):(isSpain?'Siguiente pregunta':'Question suivante')}</button>}</div></section>
 </div>
}
