import { useEffect, useState } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { createFriendChallenge, getFriendChallenges, respondFriendChallenge, startFriendChallengeSession, type FriendChallenge } from '../services/challengeApi'
import { getCurrentProfile } from '../services/profileApi'
import { getFriendships, respondFriendRequest, searchStudents, sendFriendRequest, type FriendshipsSummary, type SocialStudent } from '../services/socialApi'

const emptySummary: FriendshipsSummary = { friends: [], incoming: [], outgoing: [] }

export default function FriendsPage() {
  const navigate = useNavigate()
  const [summary, setSummary] = useState<FriendshipsSummary>(emptySummary)
  const [challenges, setChallenges] = useState<FriendChallenge[]>([])
  const [results, setResults] = useState<SocialStudent[]>([])
  const [query, setQuery] = useState('')
  const [hasUsername, setHasUsername] = useState<boolean | null>(null)
  const [busyId, setBusyId] = useState<string | null>(null)
  const [loading, setLoading] = useState(true)
  const [message, setMessage] = useState<string | null>(null)

  async function refresh() {
    const [profile, friendships, challengeRows] = await Promise.all([getCurrentProfile(), getFriendships(), getFriendChallenges()])
    setHasUsername(Boolean(profile?.username))
    setSummary(friendships)
    setChallenges(challengeRows)
  }

  useEffect(() => {
    void refresh().catch((err: Error) => setMessage(err.message)).finally(() => setLoading(false))
  }, [])

  async function runSearch(event: React.FormEvent) {
    event.preventDefault(); setMessage(null)
    try { setResults(await searchStudents(query)) } catch (err) { setMessage(err instanceof Error ? err.message : 'Recherche impossible.') }
  }

  async function invite(student: SocialStudent) {
    setBusyId(student.id); setMessage(null)
    try { await sendFriendRequest(student.id); setMessage(`Invitation envoyée à @${student.username}.`); setResults((current) => current.filter((item) => item.id !== student.id)); await refresh() }
    catch (err) { setMessage(err instanceof Error ? err.message : 'Impossible d’envoyer l’invitation.') }
    finally { setBusyId(null) }
  }

  async function answer(friendshipId: string, accept: boolean) {
    setBusyId(friendshipId); setMessage(null)
    try { await respondFriendRequest(friendshipId, accept); setMessage(accept ? 'Invitation acceptée ✓' : 'Invitation refusée.'); await refresh() }
    catch (err) { setMessage(err instanceof Error ? err.message : 'Impossible de traiter l’invitation.') }
    finally { setBusyId(null) }
  }

  async function challenge(friendId: string) {
    setBusyId(friendId); setMessage(null)
    try { await createFriendChallenge(friendId); setMessage('Défi envoyé ⚔️'); await refresh() }
    catch (err) { setMessage(err instanceof Error ? err.message : 'Impossible de lancer le défi.') }
    finally { setBusyId(null) }
  }

  async function answerChallenge(challengeId: string, accept: boolean) {
    setBusyId(challengeId); setMessage(null)
    try { await respondFriendChallenge(challengeId, accept); setMessage(accept ? 'Défi accepté. À toi de jouer !' : 'Défi refusé.'); await refresh() }
    catch (err) { setMessage(err instanceof Error ? err.message : 'Impossible de traiter le défi.') }
    finally { setBusyId(null) }
  }

  async function playChallenge(challengeId: string) {
    setBusyId(challengeId); setMessage(null)
    try {
      const sessionId = await startFriendChallengeSession(challengeId)
      navigate(`/revision?mode=challenge&session=${sessionId}&challenge=${challengeId}`)
    } catch (err) {
      setMessage(err instanceof Error ? err.message : 'Impossible de démarrer le défi.')
      setBusyId(null)
    }
  }

  if (loading) return <section className="card skeleton-card"><p>Chargement de tes amis…</p></section>

  const activeChallenges = challenges.filter((item) => item.status !== 'completed' && item.status !== 'declined' && item.status !== 'cancelled')
  const completedChallenges = challenges.filter((item) => item.status === 'completed').slice(0, 5)

  return (
    <div className="stack friends-stack">
      <section className="hero-card friends-hero"><div className="hero-copy"><span className="hero-kicker">Réviser ensemble</span><h1>Amis & défis ⚔️</h1><p>Ajoute tes camarades et affrontez-vous sur le même quiz de 10 questions.</p></div><div className="hero-orbit" aria-hidden="true"><span>🤝</span></div></section>

      {!hasUsername && <section className="card setup-card"><div><p className="eyebrow">Avant de commencer</p><h2>Choisis ton pseudo</h2><p>Un pseudo est nécessaire pour que les autres étudiants puissent te retrouver.</p></div><Link className="primary-button" to="/profil">Créer mon pseudo</Link></section>}

      {activeChallenges.length > 0 && <section className="card challenge-hub-card"><div className="section-heading"><div><p className="eyebrow">Duels</p><h2>Défis en cours</h2></div><strong>{activeChallenges.length}</strong></div><div className="people-list">{activeChallenges.map((item) => {
        const awaitingMe = item.direction === 'received' && item.status === 'pending'
        const playable = item.status === 'accepted' || item.status === 'in_progress'
        return <article className="person-row challenge-row" key={item.id}><div className="person-avatar duel-avatar">{item.opponent.avatar_url ? <img src={item.opponent.avatar_url} alt="" /> : (item.opponent.first_name || item.opponent.username || '?').slice(0,1).toUpperCase()}</div><div className="person-copy"><strong>{item.opponent.first_name || item.opponent.username}</strong><span>{item.status === 'pending' ? (awaitingMe ? 'te défie sur 10 questions' : 'invitation envoyée') : 'même quiz · 10 questions'}</span></div>{awaitingMe ? <div className="friend-actions"><button className="primary-button compact-button" onClick={() => void answerChallenge(item.id, true)} disabled={busyId===item.id}>Accepter</button><button className="secondary-button compact-button" onClick={() => void answerChallenge(item.id, false)} disabled={busyId===item.id}>Refuser</button></div> : playable ? <button className="primary-button compact-button" onClick={() => void playChallenge(item.id)} disabled={busyId===item.id}>{busyId===item.id?'…':'Jouer'}</button> : <span className="pending-chip">En attente</span>}</article>
      })}</div></section>}

      <section className="card"><div className="section-heading"><div><p className="eyebrow">Trouver un camarade</p><h2>Ajouter un ami</h2></div></div><form className="friend-search" onSubmit={runSearch}><input value={query} onChange={(event) => setQuery(event.target.value)} placeholder="Pseudo ou prénom" minLength={2}/><button className="primary-button" type="submit" disabled={query.trim().length<2}>Rechercher</button></form>{results.length>0&&<div className="people-list">{results.map((student)=><article className="person-row" key={student.id}><div className="person-avatar">{(student.first_name||student.username||'?').slice(0,1).toUpperCase()}</div><div className="person-copy"><strong>{student.first_name||student.username}</strong><span>@{student.username} · K{student.study_year??'?'} · niv. {student.level??1}</span></div><button className="secondary-button compact-button" onClick={()=>void invite(student)} disabled={busyId===student.id}>{busyId===student.id?'…':'Ajouter'}</button></article>)}</div>}</section>

      {summary.incoming.length>0&&<section className="card"><div className="section-heading"><div><p className="eyebrow">À valider</p><h2>Invitations reçues</h2></div><strong>{summary.incoming.length}</strong></div><div className="people-list">{summary.incoming.map((student)=><article className="person-row incoming" key={student.friendship_id}><div className="person-avatar">{(student.first_name||student.username||'?').slice(0,1).toUpperCase()}</div><div className="person-copy"><strong>{student.first_name||student.username}</strong><span>@{student.username} · K{student.study_year??'?'}</span></div><div className="friend-actions"><button className="primary-button compact-button" onClick={()=>void answer(student.friendship_id,true)} disabled={busyId===student.friendship_id}>Accepter</button><button className="secondary-button compact-button" onClick={()=>void answer(student.friendship_id,false)} disabled={busyId===student.friendship_id}>Refuser</button></div></article>)}</div></section>}

      <section className="card"><div className="section-heading"><div><p className="eyebrow">Mon groupe</p><h2>Mes amis</h2></div><strong>{summary.friends.length}</strong></div>{summary.friends.length===0?<div className="empty-social"><span>👋</span><strong>Ta liste est encore vide</strong><p>Recherche un camarade avec son pseudo pour l’ajouter.</p></div>:<div className="people-list">{summary.friends.map((student)=><article className="person-row" key={student.friendship_id}><div className="person-avatar">{(student.first_name||student.username||'?').slice(0,1).toUpperCase()}</div><div className="person-copy"><strong>{student.first_name||student.username}</strong><span>@{student.username} · K{student.study_year??'?'} · niv. {student.level??1}</span></div><button className="duel-button" onClick={()=>void challenge(student.id)} disabled={busyId===student.id}>⚔️ Défier</button></article>)}</div>}</section>

      {completedChallenges.length>0&&<section className="card"><div className="section-heading"><div><p className="eyebrow">Historique</p><h2>Derniers duels</h2></div></div><div className="people-list">{completedChallenges.map((item)=>{const myScore=item.direction==='sent'?item.challenger_score:item.challenged_score;const otherScore=item.direction==='sent'?item.challenged_score:item.challenger_score;return <article className="duel-result" key={item.id}><div><strong>{item.opponent.first_name||item.opponent.username}</strong><span>@{item.opponent.username}</span></div><div className="duel-score"><strong>{myScore??'-'}%</strong><span>—</span><strong>{otherScore??'-'}%</strong></div></article>})}</div></section>}

      {summary.outgoing.length>0&&<section className="card muted-card"><p className="eyebrow">En attente</p><h2>Invitations envoyées</h2><div className="people-list">{summary.outgoing.map((student)=><article className="person-row" key={student.friendship_id}><div className="person-avatar">{(student.first_name||student.username||'?').slice(0,1).toUpperCase()}</div><div className="person-copy"><strong>{student.first_name||student.username}</strong><span>@{student.username}</span></div><span className="pending-chip">En attente</span></article>)}</div></section>}

      {message&&<section className="card feedback-card"><p className="feedback">{message}</p></section>}
    </div>
  )
}
