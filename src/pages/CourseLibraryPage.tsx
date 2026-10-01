import { useEffect, useMemo, useState } from 'react'
import { Link } from 'react-router-dom'
import { getCourseLibraryV1, type CourseLibraryDocument } from '../services/courseLibraryApi'
import { getCurrentProfile } from '../services/profileApi'
import './CourseLibraryPage.css'

function formatSize(bytes: number | null) {
  if (!bytes || bytes <= 0) return null
  const mb = bytes / (1024 * 1024)
  return `${mb.toFixed(mb >= 10 ? 0 : 1)} Mo`
}

export default function CourseLibraryPage() {
  const [documents, setDocuments] = useState<CourseLibraryDocument[]>([])
  const [query, setQuery] = useState('')
  const [year, setYear] = useState<number | 'all'>('all')
  const [chapter, setChapter] = useState('all')
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    Promise.all([getCourseLibraryV1(), getCurrentProfile()])
      .then(([docs, profile]) => {
        setDocuments(docs)
        if (profile?.study_year && docs.some((doc) => doc.year?.number === profile.study_year)) {
          setYear(profile.study_year)
        }
      })
      .catch((err: Error) => setError(err.message))
  }, [])

  const years = useMemo(() => Array.from(new Set(documents.map((doc) => doc.year?.number).filter((value): value is number => typeof value === 'number'))).sort(), [documents])
  const chapters = useMemo(() => Array.from(new Set(documents.filter((doc) => year === 'all' || doc.year?.number === year).map((doc) => doc.chapter?.name).filter((value): value is string => Boolean(value)))).sort(), [documents, year])

  const filtered = useMemo(() => {
    const needle = query.trim().toLocaleLowerCase('fr')
    return documents.filter((doc) => {
      if (year !== 'all' && doc.year?.number !== year) return false
      if (chapter !== 'all' && doc.chapter?.name !== chapter) return false
      if (!needle) return true
      const haystack = [doc.title, doc.file_name, doc.subject?.name, doc.chapter?.name, ...doc.lessons.map((lesson) => lesson.title)]
        .filter(Boolean)
        .join(' ')
        .toLocaleLowerCase('fr')
      return haystack.includes(needle)
    })
  }, [chapter, documents, query, year])

  const questionTotal = filtered.reduce((sum, doc) => sum + doc.question_count, 0)
  const chapterTotal = new Set(filtered.map((doc) => doc.chapter?.name).filter(Boolean)).size

  if (error && documents.length === 0) return <section className="card"><h1>Bibliothèque indisponible</h1><p>{error}</p></section>
  if (documents.length === 0 && !error) return <section className="card skeleton-card"><p>Chargement des cours…</p></section>

  return (
    <div className="library-page">
      <section className="stats-hero">
        <div>
          <p className="eyebrow light">Bibliothèque Kineo</p>
          <h1>Tous tes cours, au même endroit.</h1>
          <p>Recherche un CM, retrouve ses leçons associées et ouvre directement le support d’origine.</p>
        </div>
        <div className="stats-hero-score"><span>Cours</span><strong>{filtered.length}</strong></div>
      </section>

      <section className="stats-grid">
        <article className="card score-card"><span>📄 Supports</span><strong>{filtered.length}</strong><small>dans la sélection</small></article>
        <article className="card score-card"><span>❓ Questions</span><strong>{questionTotal}</strong><small>liées aux cours</small></article>
        <article className="card score-card"><span>▦ Chapitres</span><strong>{chapterTotal}</strong><small>zones couvertes</small></article>
        <article className="card score-card"><span>✓ Validés</span><strong>{filtered.filter((doc) => doc.validation_status === 'validated').length}</strong><small>supports IFMK</small></article>
      </section>

      <section className="card library-toolbar">
        <label className="library-search">
          <span>Rechercher un cours</span>
          <input value={query} onChange={(event) => setQuery(event.target.value)} placeholder="Ex. hanche, genou, myologie…" type="search" />
        </label>
        <div className="library-filters">
          <select className="library-filter" value={year} onChange={(event) => { setYear(event.target.value === 'all' ? 'all' : Number(event.target.value)); setChapter('all') }} aria-label="Filtrer par année">
            <option value="all">Toutes les années</option>
            {years.map((value) => <option key={value} value={value}>K{value}</option>)}
          </select>
          <select className="library-filter" value={chapter} onChange={(event) => setChapter(event.target.value)} aria-label="Filtrer par chapitre">
            <option value="all">Tous les chapitres</option>
            {chapters.map((value) => <option key={value} value={value}>{value}</option>)}
          </select>
        </div>
      </section>

      <section className="card">
        <div className="library-results-head">
          <div><p className="eyebrow">Cours disponibles</p><h2>{year === 'all' ? 'Tous les supports' : `Supports K${year}`}</h2></div>
          <span className="library-count">{filtered.length} résultat{filtered.length > 1 ? 's' : ''}</span>
        </div>

        {filtered.length === 0 ? (
          <div className="library-empty"><strong>Aucun cours trouvé</strong><span>Essaie un autre mot-clé ou retire un filtre.</span></div>
        ) : (
          <div className="library-list" style={{ marginTop: 14 }}>
            {filtered.map((doc) => {
              const size = formatSize(doc.file_size)
              const firstLesson = doc.lessons[0]
              return (
                <article className="library-doc" key={doc.id}>
                  <div className="library-doc-head">
                    <div className="library-doc-icon">📄</div>
                    <div>
                      <h3>{doc.title}</h3>
                      <p className="library-meta">{doc.subject?.name ?? 'Matière non renseignée'}{doc.chapter ? ` · ${doc.chapter.name}` : ''}</p>
                    </div>
                  </div>

                  <div className="library-badges">
                    {doc.year && <span className="library-badge">K{doc.year.number}</span>}
                    {doc.validation_status === 'validated' && <span className="library-badge validated">✓ Support IFMK validé</span>}
                    {size && <span className="library-badge">{size}</span>}
                  </div>

                  <div className="library-stats">
                    <div className="library-stat"><small>Questions associées</small><strong>{doc.question_count}</strong></div>
                    <div className="library-stat"><small>Leçons associées</small><strong>{doc.lessons.length}</strong></div>
                  </div>

                  {doc.lessons.length > 0 && <div className="library-lessons">
                    {doc.lessons.slice(0, 4).map((lesson) => <Link className="library-lesson-link" key={lesson.id} to={`/lesson/${lesson.id}`}>{lesson.title}</Link>)}
                  </div>}

                  <div className="library-actions">
                    {doc.source_url
                      ? <a className="primary-button" href={doc.source_url} target="_blank" rel="noreferrer">Ouvrir le PDF</a>
                      : <span className="secondary-button" aria-disabled="true">PDF indisponible</span>}
                    {firstLesson
                      ? <Link className="secondary-button" to={`/lesson/${firstLesson.id}`}>Voir les leçons</Link>
                      : <Link className="secondary-button" to="/parcours">Voir le parcours</Link>}
                  </div>
                </article>
              )
            })}
          </div>
        )}
      </section>

      {error && <section className="card"><p className="feedback">{error}</p></section>}
    </div>
  )
}
