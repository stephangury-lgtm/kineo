import { useEffect,useMemo,useState } from 'react'
import { Link,useParams } from 'react-router-dom'
import { CompactReferences,ReadableCourseContent } from '../components/ReadableCourseContent'
import { getCurrentProgram } from '../curriculum/programs'
import { getTopic,getTopicLessons,getTopicQuiz,submitCurriculumTopicAnswer,type CurriculumAnswerPayload,type CurriculumAnswerResult,type CurriculumHotspot,type CurriculumLesson,type CurriculumMatchPair,type CurriculumQuizQuestion,type CurriculumQuizOption,type ProgramCatalogTopic } from '../services/programCatalogApi'
import type { CurriculumVersion } from '../services/programApi'
import '../course-reading.css'

function normalizeAnswer(value:string){
 return value.trim().toLocaleLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g,'').replace(/\s+/g,' ')
}

function acceptedAnswers(q:CurriculumQuizQuestion){
 const raw=q.accepted_answers
 if(Array.isArray(raw))return raw.map(String)
 const fallback=q.options.find((o:CurriculumQuizOption)=>o.correct)?.text
 return fallback?[fallback]:[]
}

function hotspots(q:CurriculumQuizQuestion):CurriculumHotspot[]{
 const meta=q.metadata
 if(!meta||typeof meta!=='object'||!('hotspots' in meta))return[]
 const raw=(meta as {hotspots?:unknown}).hotspots
 return Array.isArray(raw)?raw.filter((item):item is CurriculumHotspot=>Boolean(item&&typeof item==='object'&&'id' in item&&'x' in item&&'y' in item)):[]
}

function matchingPairs(q:CurriculumQuizQuestion):CurriculumMatchPair[]{
 const meta=q.metadata
 if(!meta||typeof meta!=='object'||!('pairs' in meta))return[]
 const raw=(meta as {pairs?:unknown}).pairs
 return Array.isArray(raw)?raw.filter((item):item is CurriculumMatchPair=>Boolean(item&&typeof item==='object'&&'left' in item&&'right' in item)):[]
}

function stableRank(value:string){
 let hash=2166136261
 for(let index=0;index<value.length;index++){
  hash^=value.charCodeAt(index)
  hash=Math.imul(hash,16777619)
 }
 return hash>>>0
}

function stableShuffle(values:string[],seed:string){
 return [...values].sort((a,b)=>stableRank(`${seed}:${a}`)-stableRank(`${seed}:${b}`))
}

function isLocallyCorrect(q:CurriculumQuizQuestion,answer:string,matching:Record<string,string>){
 if(q.question_type==='fill_blank'){
  const normalized=normalizeAnswer(answer)
  return acceptedAnswers(q).some(candidate=>normalizeAnswer(candidate)===normalized)
 }
 if(q.question_type==='visual_hotspot')return hotspots(q).some(point=>point.correct&&point.id===answer)
 if(q.question_type==='matching')return matchingPairs(q).every(pair=>normalizeAnswer(matching[pair.left]??'')===normalizeAnswer(pair.right))
 const correct=q.options.find((o:CurriculumQuizOption)=>o.correct)?.text
 return answer===correct
}

function formatLabel(type:CurriculumQuizQuestion['question_type'],isEs:boolean){
 if(type==='fill_blank')return isEs?'Completar':'Texte à trous'
 if(type==='visual_hotspot')return isEs?'Zona anatómica':'Zone anatomique'
 if(type==='clinical_case')return isEs?'Caso clínico':'Cas clinique'
 if(type==='matching')return isEs?'Asociar':'Association'
 return isEs?'QCM':'QCM'
}

export default function CurriculumTopicPage(){
 const {topicId}=useParams()
 const program=getCurrentProgram()
 const isEs=program.id==='kineo-es'
 const curriculumVersion:CurriculumVersion=program.id==='ifsi-fr'?((localStorage.getItem(`healthapp_curriculum_${program.id}`) as CurriculumVersion|null)??'2009'):'default'
 const [topic,setTopic]=useState<ProgramCatalogTopic|null>(null)
 const [lessons,setLessons]=useState<CurriculumLesson[]>([])
 const [quiz,setQuiz]=useState<CurriculumQuizQuestion[]>([])
 const [loading,setLoading]=useState(true)
 const [error,setError]=useState<string|null>(null)
 const [answers,setAnswers]=useState<Record<string,string>>({})
 const [matchingAnswers,setMatchingAnswers]=useState<Record<string,Record<string,string>>>({})
 const [checked,setChecked]=useState<Record<string,boolean>>({})
 const [results,setResults]=useState<Record<string,CurriculumAnswerResult>>({})
 const [submitting,setSubmitting]=useState<string|null>(null)
 const [quizError,setQuizError]=useState<string|null>(null)
 const [quizStarted,setQuizStarted]=useState(()=>typeof window!=='undefined'&&window.location.hash==='#qcm')

 useEffect(()=>{
  if(!topicId)return
  let cancelled=false
  setLoading(true);setError(null);setTopic(null);setLessons([]);setQuiz([]);setAnswers({});setMatchingAnswers({});setChecked({});setResults({});setQuizError(null);setQuizStarted(typeof window!=='undefined'&&window.location.hash==='#qcm')
  getTopic(topicId,program.id,curriculumVersion)
   .then(async t=>{
    const [l,q]=await Promise.all([getTopicLessons(t.id),getTopicQuiz(t.id)])
    if(cancelled)return
    setTopic(t);setLessons(l);setQuiz(q)
   })
   .catch(()=>{if(!cancelled)setError(isEs?'Este tema no pertenece al plan de estudios activo o no está disponible.':'Ce chapitre n’appartient pas au cursus ou au référentiel actif.')})
   .finally(()=>{if(!cancelled)setLoading(false)})
  return()=>{cancelled=true}
 },[topicId,isEs,program.id,curriculumVersion])

 const score=useMemo(()=>quiz.reduce((total,q)=>{
  if(!checked[q.id])return total
  const server=results[q.id]
  const local=isLocallyCorrect(q,answers[q.id]??'',matchingAnswers[q.id]??{})
  return total+(server?.correct??local?1:0)
 },0),[quiz,answers,matchingAnswers,checked,results])
 const checkedCount=Object.keys(checked).filter(id=>checked[id]).length

 function buildPayload(q:CurriculumQuizQuestion):CurriculumAnswerPayload{
  if(q.question_type==='visual_hotspot')return {hotspot_id:answers[q.id]??''}
  if(q.question_type==='matching')return {pairs:matchingPairs(q).map(pair=>({left:pair.left,right:matchingAnswers[q.id]?.[pair.left]??''}))}
  return {text:answers[q.id]??''}
 }

 function canSubmit(q:CurriculumQuizQuestion){
  if(checked[q.id]||submitting===q.id)return false
  if(q.question_type==='matching'){
   const pairs=matchingPairs(q)
   return pairs.length>0&&pairs.every(pair=>Boolean(matchingAnswers[q.id]?.[pair.left]))
  }
  return Boolean((answers[q.id]??'').trim())
 }

 function restartQuiz(){
  setAnswers({});setMatchingAnswers({});setChecked({});setResults({});setQuizError(null);setQuizStarted(true)
  if(typeof window!=='undefined'){window.location.hash='qcm';window.requestAnimationFrame(()=>document.getElementById('qcm')?.scrollIntoView({behavior:'smooth',block:'start'}))}
 }

 async function validateQuestion(q:CurriculumQuizQuestion){
  if(!canSubmit(q))return
  setSubmitting(q.id);setQuizError(null)
  try{
   const result=await submitCurriculumTopicAnswer(q.id,buildPayload(q))
   setResults(current=>({...current,[q.id]:result}))
   setChecked(current=>({...current,[q.id]:true}))
   window.dispatchEvent(new Event('kineo-progress-updated'))
  }catch(e){
   setQuizError(e instanceof Error?e.message:(isEs?'No se pudo validar la respuesta.':'Impossible de valider la réponse.'))
  }finally{setSubmitting(null)}
 }

 if(loading)return <div className="card"><p>{isEs?'Cargando la ficha…':'Chargement de la fiche…'}</p></div>
 if(error||!topic)return <div className="card"><p>{error??(isEs?'Tema no encontrado.':'Chapitre introuvable.')}</p><Link className="primary-button" to="/parcours">{isEs?'Volver al itinerario':'Retour au parcours'}</Link></div>

 return <div className="stack curriculum-learning-page">
  <section className="stats-hero curriculum-learning-hero">
   <div className="stats-hero-copy">
    <p className="eyebrow light">{program.flag} {isEs?'Tema':'Chapitre'} · {program.shortName}</p>
    <h1>{topic.name}</h1>
    {topic.description&&<p>{topic.description}</p>}
    <div className="curriculum-learning-actions"><a className="secondary-button" href="#fiche">📖 {isEs?'Leer la ficha':'Lire la fiche'}</a><a className="primary-button" href="#qcm" onClick={()=>setQuizStarted(true)}>✅ {isEs?'Repaso activo':'Révision active'}</a></div>
   </div>
   <div className="stats-hero-score"><span>Quiz</span><strong>{quiz.length}</strong></div>
  </section>
  <section className="stats-grid">
   <article className="card score-card"><span>📖 {isEs?'Fichas':'Fiches'}</span><strong>{lessons.length}</strong><small>{isEs?'contenido publicado':'contenu publié'}</small></article>
   <article className="card score-card"><span>❓ {isEs?'Preguntas':'Questions'}</span><strong>{quiz.length}</strong><small>{isEs?'ejercicios disponibles':'exercices disponibles'}</small></article>
   <article className="card score-card"><span>✅ {isEs?'Respondidas':'Répondues'}</span><strong>{checkedCount}</strong><small>{quiz.length?Math.round((checkedCount/quiz.length)*100):0}%</small></article>
   <article className="card score-card"><span>🎯 {isEs?'Puntuación':'Score'}</span><strong>{checkedCount?Math.round((score/checkedCount)*100):0}%</strong><small>{checkedCount?`${score}/${checkedCount}`:(isEs?'por empezar':'à démarrer')}</small></article>
  </section>
  <Link className="text-link" to="/parcours">← {isEs?'Volver al itinerario':'Retour au parcours'}</Link>

  <section className="card" id="fiche">
   <div className="section-heading"><div><p className="eyebrow">{isEs?'Curso':'Cours'}</p><h2>{isEs?'Comprender, aplicar y recordar':'Comprendre, appliquer et retenir'}</h2></div><span className="program-status live">{lessons.length} {isEs?(lessons.length>1?'fichas':'ficha'):`fiche${lessons.length>1?'s':''}`}</span></div>
   {lessons.length===0?<div className="admin-empty"><span>📚</span><div><strong>{isEs?'Ficha pendiente de contenido.':'Fiche en attente de contenu.'}</strong><p>{isEs?'El tema está identificado, pero todavía no hay material validado publicado.':'Le chapitre est identifié mais aucun support exploitable n’a encore été publié.'}</p></div></div>:<div className="course-reading-shell">{lessons.map(lesson=><article className="curriculum-lesson course-reading-card" key={lesson.id}>
    <h3>{lesson.title}</h3>
    {lesson.summary&&<p className="curriculum-summary">{lesson.summary}</p>}
    <ReadableCourseContent content={lesson.content}/>
    {Array.isArray(lesson.key_points)&&lesson.key_points.length>0&&<div className="course-key-points-compact"><strong>{isEs?'Puntos clave':'À retenir'}</strong><ul>{(lesson.key_points as unknown[]).map((point,i)=><li key={i}>{String(point)}</li>)}</ul></div>}
    <CompactReferences sources={lesson.source_files} label={isEs?'Referencias':'Références'}/>
   </article>)}</div>}
  </section>

  <section className="card centered"><p className="eyebrow">{isEs?'Pasar a la práctica':'Passage à l’action'}</p><h2>{isEs?'Comprueba lo que has retenido':'Vérifie ce que tu as retenu'}</h2><p>{isEs?'Una serie corta de preguntas para transformar la lectura en memorización activa.':'Une courte série ciblée pour transformer la lecture en mémorisation active.'}</p><a className="primary-button wide" href="#qcm" onClick={()=>setQuizStarted(true)}>{isEs?`Empezar el quiz (${quiz.length} preguntas)`:`Lancer le quiz (${quiz.length} questions)`}</a></section>

  {quizStarted&&<section className="card" id="qcm">
   <div className="section-heading"><div><p className="eyebrow">{isEs?'Repaso activo':'Révision active'}</p><h2>{isEs?'Pon a prueba tus conocimientos':'Teste tes acquis'}</h2></div>{quiz.length>0&&<span className="program-status foundation">{checkedCount}/{quiz.length} {isEs?'respondidas':`répondu${quiz.length>1?'s':''}`}</span>}</div>
   {quizError&&<p className="form-error">{quizError}</p>}
   {quiz.length===0?<div className="admin-empty"><span>❓</span><div><strong>{isEs?'Ejercicios en preparación.':'Exercices en préparation.'}</strong><p>{isEs?'La ficha se puede consultar, pero los ejercicios todavía no están publicados.':'La fiche est consultable mais les exercices de ce chapitre ne sont pas encore publiés.'}</p></div></div>:<div className="curriculum-quiz-list">{quiz.map((q,index)=>{
    const selected=answers[q.id]??''
    const isChecked=!!checked[q.id]
    const localCorrect=isLocallyCorrect(q,selected,matchingAnswers[q.id]??{})
    const correct=results[q.id]?.correct??localCorrect
    const accepted=acceptedAnswers(q)
    const points=hotspots(q)
    const correctPoint=points.find(point=>point.correct)
    const pairs=matchingPairs(q)
    const rightItems=stableShuffle([...new Set(pairs.map(pair=>pair.right))],q.id)
    return <article className="curriculum-quiz-card" key={q.id}>
     <div style={{display:'flex',justifyContent:'space-between',gap:12,alignItems:'center'}}><strong>{isEs?'Pregunta':'Question'} {index+1}</strong><span className="program-status foundation">{formatLabel(q.question_type,isEs)}</span></div>
     <p>{q.question_text}</p>
     {q.image_url&&<div style={{position:'relative',maxWidth:720,margin:'12px auto'}}><img src={q.image_url} alt={isEs?'Soporte anatómico':'Support anatomique'} style={{display:'block',width:'100%',borderRadius:16}}/>{q.question_type==='visual_hotspot'&&points.map(point=>{
      const selectedPoint=selected===point.id
      const revealCorrect=isChecked&&point.correct
      const revealWrong=isChecked&&selectedPoint&&!point.correct
      return <button key={point.id} type="button" aria-label={point.label??(isEs?'Zona anatómica':'Zone anatomique')} disabled={isChecked} onClick={()=>setAnswers(current=>({...current,[q.id]:point.id}))} style={{position:'absolute',left:`${point.x}%`,top:`${point.y}%`,transform:'translate(-50%,-50%)',width:46,height:46,borderRadius:'50%',border:selectedPoint?'4px solid currentColor':'2px solid currentColor',background:revealCorrect?'rgba(195,255,205,.94)':revealWrong?'rgba(255,205,205,.94)':'rgba(255,255,255,.90)',cursor:isChecked?'default':'pointer',display:'grid',placeItems:'center',fontWeight:800}}>{selectedPoint?'✓':revealCorrect?'●':''}</button>
     })}</div>}
     {q.question_type==='fill_blank'?<input className="text-input" type="text" value={selected} disabled={isChecked} placeholder={isEs?'Escribe tu respuesta':'Écris ta réponse'} onChange={event=>setAnswers(current=>({...current,[q.id]:event.target.value}))}/>:q.question_type==='matching'?<div className="matching-grid">{pairs.map(pair=><label className="matching-row" key={pair.left}><span>{pair.left}</span><select value={matchingAnswers[q.id]?.[pair.left]??''} disabled={isChecked} onChange={event=>setMatchingAnswers(current=>({...current,[q.id]:{...(current[q.id]??{}),[pair.left]:event.target.value}}))}><option value="">{isEs?'Elegir…':'Choisir…'}</option>{rightItems.map(right=><option key={right} value={right}>{right}</option>)}</select></label>)}</div>:q.question_type!=='visual_hotspot'?<div className="curriculum-options">{q.options.map((option:CurriculumQuizOption)=><label className={`curriculum-option ${isChecked&&option.correct?'correct':''} ${isChecked&&selected===option.text&&!option.correct?'incorrect':''}`} key={option.text}><input type="radio" name={q.id} value={option.text} checked={selected===option.text} disabled={isChecked} onChange={()=>setAnswers(current=>({...current,[q.id]:option.text}))}/><span>{option.text}</span></label>)}</div>:null}
     <button className="primary-button wide" type="button" disabled={!canSubmit(q)} onClick={()=>void validateQuestion(q)}>{submitting===q.id?(isEs?'Validando…':'Validation…'):(isEs?'Validar mi respuesta':'Valider ma réponse')}</button>
     {isChecked&&<div className={`curriculum-feedback ${correct?'success':'error'}`}><strong>{correct?(isEs?'Respuesta correcta ✅':'Bonne réponse ✅'):(isEs?'Para repasar 💡':'À revoir 💡')}</strong>{!correct&&q.question_type==='fill_blank'&&accepted.length>0&&<p>{isEs?'Respuesta esperada':'Réponse attendue'} : {results[q.id]?.correct_answer??accepted[0]}</p>}{!correct&&q.question_type==='visual_hotspot'&&correctPoint?.label&&<p>{isEs?'Zona correcta':'Bonne zone'} : {correctPoint.label}</p>}{!correct&&q.question_type==='matching'&&pairs.length>0&&<ul>{pairs.map(pair=><li key={pair.left}>{pair.left} → {pair.right}</li>)}</ul>}{q.explanation&&<p>{q.explanation}</p>}{results[q.id]?.xp_earned!=null&&<small>+{results[q.id].xp_earned} XP</small>}{q.source_label&&<small>{q.source_label}</small>}</div>}
    </article>
   })}</div>}
   {checkedCount>0&&checkedCount<quiz.length&&<p className="curriculum-score">{isEs?'Puntuación actual':'Score actuel'} : <strong>{score}/{checkedCount}</strong></p>}
  </section>}
  {quizStarted&&quiz.length>0&&checkedCount===quiz.length&&<div className="stack"><section className="session-complete"><div className="completion-icon">{Math.round((score/quiz.length)*100)>=80?'🏆':Math.round((score/quiz.length)*100)>=60?'🎉':'💪'}</div><p className="eyebrow">{isEs?'Repaso completado':'Révision terminée'}</p><h1>{Math.round((score/quiz.length)*100)>=80?(isEs?'¡Excelente trabajo!':'Excellent travail !'):Math.round((score/quiz.length)*100)>=60?(isEs?'¡Buen progreso!':'Belle progression !'):(isEs?'Sigue así, estás progresando.':'Continue, tu progresses !')}</h1><div className="completion-score">{Math.round((score/quiz.length)*100)}%</div><p>{score}/{quiz.length} {isEs?'respuestas correctas':'bonnes réponses'}</p></section><section className="completion-grid"><article className="card"><span>✅ {isEs?'Correctas':'Bonnes réponses'}</span><strong>{score}</strong></article><article className="card"><span>❓ {isEs?'Preguntas':'Questions'}</span><strong>{quiz.length}</strong></article><article className="card"><span>🎯 {isEs?'Puntuación':'Score'}</span><strong>{Math.round((score/quiz.length)*100)}%</strong></article></section><div className="completion-actions"><button className="primary-button" type="button" onClick={restartQuiz}>{isEs?'Repetir':'Rejouer'}</button><Link className="secondary-button" to="/parcours">{isEs?'Volver al temario':'Retour au parcours'}</Link><Link className="secondary-button" to="/stats">{isEs?'Ver mi progreso':'Voir mes statistiques'}</Link><Link className="text-link" to="/rewards">{isEs?'Ver mis logros':'Voir mes récompenses'}</Link></div></div>}
 </div>
}
