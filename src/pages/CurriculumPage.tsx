import { useEffect, useMemo, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { getCurriculumV2, startLessonQuizV2, type CurriculumYear } from '../services/curriculumApi'
import { getCurrentProfile } from '../services/profileApi'
import './CurriculumPage.css'

export default function CurriculumPage() {
  const navigate = useNavigate()
  const [years, setYears] = useState<CurriculumYear[]>([])
  const [selectedYear, setSelectedYear] = useState<number | 'all'>('all')
  const [profileYear, setProfileYear] = useState<number | null>(null)
  const [busyLesson, setBusyLesson] = useState<string | null>(null)
  const [busySubject, setBusySubject] = useState<string | null>(null)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    Promise.all([getCurriculumV2(), getCurrentProfile()])
      .then(([curriculum, profile]) => {
        setYears(curriculum)
        setProfileYear(profile?.study_year ?? null)
        if (profile?.study_year) setSelectedYear(profile.study_year)
      })
      .catch((err: Error) => setError(err.message))
  }, [])

  const visibleYears = useMemo(() => selectedYear === 'all' ? years : years.filter((year) => year.number === selectedYear), [selectedYear, years])
  const totalSubjects = visibleYears.reduce((sum, year) => sum + year.subjects.length, 0)
  const totalQuestions = visibleYears.reduce((sum, year) => sum + year.subjects.reduce((subjectSum, subject) => subjectSum + subject.chapters.reduce((chapterSum, chapter) => chapterSum + chapter.published_questions, 0), 0), 0)

  async function launchLesson(lessonId: string) {
    setBusyLesson(lessonId); setError(null)
    try { const sessionId = await startLessonQuizV2(lessonId, 10); navigate(`/revision?mode=lesson&session=${encodeURIComponent(sessionId)}`) }
    catch (err) { setError(err instanceof Error ? err.message : 'Impossible de démarrer ce quiz.'); setBusyLesson(null) }
  }

  function launchSubject(subjectId: string, subjectName: string) {
    setBusySubject(subjectId)
    navigate(`/revision-matiere?subjectId=${encodeURIComponent(subjectId)}&subject=${encodeURIComponent(subjectName)}`)
  }

  if (error && years.length === 0) return <section className="card"><h1>Parcours indisponible</h1><p>{error}</p></section>
  if (years.length === 0) return <section className="card skeleton-card"><p>Chargement du parcours pédagogique…</p></section>

  return <div className="curriculum-page">
    <section className="stats-hero"><div><p className="eyebrow light">Ton parcours Kineo</p><h1>Apprends dans l’ordre, révise au bon moment.</h1><p>Retrouve les contenus publiés de ton année, suis ta maîtrise et lance un quiz ciblé en un geste.</p></div><div className="stats-hero-score"><span>Année</span><strong>{selectedYear === 'all' ? 'K1–K4' : `K${selectedYear}`}</strong></div></section>
    <section className="stats-grid"><article className="card score-card"><span>📚 Matières</span><strong>{totalSubjects}</strong><small>dans la sélection</small></article><article className="card score-card"><span>❓ Questions</span><strong>{totalQuestions}</strong><small>{totalQuestions>0?'validées et jouables':'contenus en préparation'}</small></article><article className="card score-card"><span>🎓 Années</span><strong>{visibleYears.length}</strong><small>{selectedYear === 'all' ? 'parcours complet' : 'année active'}</small></article><article className="card score-card"><span>🧠 Objectif</span><strong>90%</strong><small>maîtrise solide</small></article></section>
    <section className="card"><div className="section-heading"><div><p className="eyebrow">Filtrer</p><h2>Choisis ton année</h2></div></div><label className="text-answer-wrap"><span>Année affichée</span><select className="text-answer" value={selectedYear} onChange={(event) => setSelectedYear(event.target.value === 'all' ? 'all' : Number(event.target.value))}>{years.map((year) => <option key={year.id} value={year.number}>K{year.number} · {year.name}</option>)}<option value="all">Toutes les années</option></select></label>{selectedYear==='all'&&profileYear&&<p className="field-hint">Tu peux consulter K1–K4, mais les quiz restent limités à ton année active K{profileYear}.</p>}</section>
    {visibleYears.map((year) => {const yearQuestions=year.subjects.reduce((sum,subject)=>sum+subject.chapters.reduce((chapterSum,chapter)=>chapterSum+chapter.published_questions,0),0);return <section className="card" key={year.id}><div className="section-heading"><div><p className="eyebrow">Année {year.number}</p><h2>K{year.number} · {year.name}</h2></div><span className={yearQuestions>0?'admin-ok':'admin-alert'}>{yearQuestions>0?`${yearQuestions} questions`:'En préparation'}</span></div>{year.description && <p>{year.description}</p>}{yearQuestions===0&&<div className="admin-empty"><span>📚</span><div><strong>Les contenus K{year.number} ne sont pas encore publiés.</strong><p>La structure du programme reste visible, mais aucun quiz ne sera proposé tant que les CM correspondants n’auront pas été intégrés et validés.</p></div></div>}{year.subjects.length === 0 ? <p>Aucune matière configurée pour cette année pour le moment.</p> : <div className="subject-list">{year.subjects.map((subject) => {const subjectQuestions=subject.chapters.reduce((sum,chapter)=>sum+chapter.published_questions,0);const canLaunch=profileYear===year.number&&subjectQuestions>0;return <details key={subject.id}><summary className="subject-row"><div><strong>{subject.icon ? `${subject.icon} ` : ''}{subject.name}</strong><span>{subjectQuestions>0?`${subject.chapter_count} chapitre${subject.chapter_count > 1 ? 's' : ''} · ${subjectQuestions} questions`:'Contenu en préparation'}</span></div><span>Voir</span></summary><div className="quick-grid">{subjectQuestions>0?<button className="primary-button" onClick={()=>launchSubject(subject.id,subject.name)} disabled={!canLaunch||busySubject===subject.id}>{busySubject===subject.id?'Préparation…':canLaunch?'Réviser cette matière':`Consultation K${year.number}`}</button>:<div className="quick-card"><span>📚</span><strong>Quiz indisponible</strong><small>En attente de contenu validé</small></div>}</div><div className="stack">{subject.chapters.map((chapter)=><article key={chapter.id} className="card"><div className="section-heading"><div><p className="eyebrow">Chapitre</p><h3>{chapter.name}</h3></div><strong>{chapter.published_questions}</strong></div>{chapter.description&&<p>{chapter.description}</p>}<p>{chapter.published_questions>0?`${chapter.published_questions} question${chapter.published_questions>1?'s':''} validée${chapter.published_questions>1?'s':''}`:'Aucune question publiée pour ce chapitre'}</p>{chapter.lessons.length===0?<p>{chapter.published_questions>0?'Les questions de ce chapitre ne sont pas encore regroupées en leçons publiées.':'Les cours seront affichés ici après validation.'}</p>:chapter.lessons.map((lesson)=><div className="subject-progress" key={lesson.id}><div className="subject-row"><div><strong>{lesson.title}</strong>{lesson.summary&&<span>{lesson.summary}</span>}<span>{lesson.published_questions>0?`${lesson.published_questions} questions · couverture ${lesson.coverage_percent}%`:'Contenu en préparation'}</span></div><div className="subject-score"><strong>{lesson.mastery_percent}%</strong><span>maîtrise</span></div></div><div className="progress-track small"><div className="progress-fill" style={{width:`${Math.min(100,lesson.mastery_percent)}%`}}/></div><div className="quick-grid"><button className="secondary-button" onClick={()=>navigate(`/lesson/${lesson.id}`)}>Lire le cours</button>{lesson.published_questions>0?<button className="primary-button" onClick={()=>launchLesson(lesson.id)} disabled={!canLaunch||busyLesson===lesson.id}>{busyLesson===lesson.id?'Préparation…':canLaunch?'Lancer le quiz':`Quiz K${year.number}`}</button>:<button className="primary-button" disabled>Quiz en préparation</button>}</div></div>)}</article>)}</div></details>})}</div>}</section>})}
    {error&&<section className="card"><p className="feedback">{error}</p></section>}
  </div>
}
