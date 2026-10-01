import { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import { getCurrentProfile } from '../services/profileApi'
import {
  getFriendships,
  respondFriendRequest,
  searchStudents,
  sendFriendRequest,
  type FriendshipsSummary,
  type SocialStudent,
} from '../services/socialApi'

const emptySummary: FriendshipsSummary = { friends: [], incoming: [], outgoing: [] }

export default function FriendsPage() {
  const [summary, setSummary] = useState<FriendshipsSummary>(emptySummary)
  const [results, setResults] = useState<SocialStudent[]>([])
  const [query, setQuery] = useState('')
  const [hasUsername, setHasUsername] = useState<boolean | null>(null)
  const [busyId, setBusyId] = useState<string | null>(null)
  const [loading, setLoading] = useState(true)
  const [message, setMessage] = useState<string | null>(null)

  async function refresh() {
    const [profile, friendships] = await Promise.all([getCurrentProfile(), getFriendships()])
    setHasUsername(Boolean(profile?.username))
    setSummary(friendships)
  }

  useEffect(() => {
    void refresh()
      .catch((err: Error) => setMessage(err.message))
      .finally(() => setLoading(false))
  }, [])

  async function runSearch(event: React.FormEvent) {
    event.preventDefault()
    setMessage(null)
    try {
      setResults(await searchStudents(query))
    } catch (err) {
      setMessage(err instanceof Error ? err.message : 'Recherche impossible.')
    }
  }

  async function invite(student: SocialStudent) {
    setBusyId(student.id)
    setMessage(null)
    try {
      await sendFriendRequest(student.id)
      setMessage(`Invitation envoyée à @${student.username}.`)
      setResults((current) => current.filter((item) => item.id !== student.id))
      await refresh()
    } catch (err) {
      setMessage(err instanceof Error ? err.message : 'Impossible d’envoyer l’invitation.')
    } finally {
      setBusyId(null)
    }
  }

  async function answer(friendshipId: string, accept: boolean) {
    setBusyId(friendshipId)
    setMessage(null)
    try {
      await respondFriendRequest(friendshipId, accept)
      setMessage(accept ? 'Invitation acceptée ✓' : 'Invitation refusée.')
      await refresh()
    } catch (err) {
      setMessage(err instanceof Error ? err.message : 'Impossible de traiter l’invitation.')
    } finally {
      setBusyId(null)
    }
  }

  if (loading) return <section className="card skeleton-card"><p>Chargement de tes amis…</p></section>

  return (
    <div className="stack friends-stack">
      <section className="hero-card friends-hero">
        <div className="hero-copy">
          <span className="hero-kicker">Réviser ensemble</span>
          <h1>Mes amis 👥</h1>
          <p>Ajoute tes camarades maintenant. Les défis de quiz utiliseront cette liste d’amis.</p>
        </div>
        <div className="hero-orbit" aria-hidden="true"><span>🤝</span></div>
      </section>

      {!hasUsername && (
        <section className="card setup-card">
          <div><p className="eyebrow">Avant de commencer</p><h2>Choisis ton pseudo</h2><p>Un pseudo est nécessaire pour que les autres étudiants puissent te retrouver.</p></div>
          <Link className="primary-button" to="/profil">Créer mon pseudo</Link>
        </section>
      )}

      <section className="card">
        <div className="section-heading"><div><p className="eyebrow">Trouver un camarade</p><h2>Ajouter un ami</h2></div></div>
        <form className="friend-search" onSubmit={runSearch}>
          <input value={query} onChange={(event) => setQuery(event.target.value)} placeholder="Pseudo ou prénom" minLength={2} />
          <button className="primary-button" type="submit" disabled={query.trim().length < 2}>Rechercher</button>
        </form>
        {results.length > 0 && <div className="people-list">{results.map((student) => (
          <article className="person-row" key={student.id}>
            <div className="person-avatar">{(student.first_name || student.username || '?').slice(0, 1).toUpperCase()}</div>
            <div className="person-copy"><strong>{student.first_name || student.username}</strong><span>@{student.username} · K{student.study_year ?? '?'} · niv. {student.level ?? 1}</span></div>
            <button className="secondary-button compact-button" onClick={() => invite(student)} disabled={busyId === student.id}>{busyId === student.id ? '…' : 'Ajouter'}</button>
          </article>
        ))}</div>}
      </section>

      {summary.incoming.length > 0 && <section className="card">
        <div className="section-heading"><div><p className="eyebrow">À valider</p><h2>Invitations reçues</h2></div><strong>{summary.incoming.length}</strong></div>
        <div className="people-list">{summary.incoming.map((student) => (
          <article className="person-row incoming" key={student.friendship_id}>
            <div className="person-avatar">{(student.first_name || student.username || '?').slice(0, 1).toUpperCase()}</div>
            <div className="person-copy"><strong>{student.first_name || student.username}</strong><span>@{student.username} · K{student.study_year ?? '?'}</span></div>
            <div className="friend-actions"><button className="primary-button compact-button" onClick={() => answer(student.friendship_id, true)} disabled={busyId === student.friendship_id}>Accepter</button><button className="secondary-button compact-button" onClick={() => answer(student.friendship_id, false)} disabled={busyId === student.friendship_id}>Refuser</button></div>
          </article>
        ))}</div>
      </section>}

      <section className="card">
        <div className="section-heading"><div><p className="eyebrow">Mon groupe</p><h2>Mes amis</h2></div><strong>{summary.friends.length}</strong></div>
        {summary.friends.length === 0 ? <div className="empty-social"><span>👋</span><strong>Ta liste est encore vide</strong><p>Recherche un camarade avec son pseudo pour l’ajouter.</p></div> : <div className="people-list">{summary.friends.map((student) => (
          <article className="person-row" key={student.friendship_id}>
            <div className="person-avatar">{(student.first_name || student.username || '?').slice(0, 1).toUpperCase()}</div>
            <div className="person-copy"><strong>{student.first_name || student.username}</strong><span>@{student.username} · K{student.study_year ?? '?'} · niv. {student.level ?? 1}</span></div>
            <span className="profile-chip">Ami</span>
          </article>
        ))}</div>}
      </section>

      {summary.outgoing.length > 0 && <section className="card muted-card">
        <p className="eyebrow">En attente</p><h2>Invitations envoyées</h2>
        <div className="people-list">{summary.outgoing.map((student) => <article className="person-row" key={student.friendship_id}><div className="person-avatar">{(student.first_name || student.username || '?').slice(0, 1).toUpperCase()}</div><div className="person-copy"><strong>{student.first_name || student.username}</strong><span>@{student.username}</span></div><span className="pending-chip">En attente</span></article>)}</div>
      </section>}

      {message && <section className="card feedback-card"><p className="feedback">{message}</p></section>}
    </div>
  )
}
