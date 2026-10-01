import { useEffect,useState } from 'react'
import { Link } from 'react-router-dom'
import { getFriendLeaderboard,type FriendLeaderboardRow } from '../services/socialApi'

export default function LeaderboardPage(){
 const [rows,setRows]=useState<FriendLeaderboardRow[]>([])
 const [error,setError]=useState<string|null>(null)
 useEffect(()=>{getFriendLeaderboard().then(setRows).catch((e:Error)=>setError(e.message))},[])
 if(error)return <section className="card"><h1>Classement indisponible</h1><p>{error}</p></section>
 if(!rows.length)return <section className="card skeleton-card"><p>Calcul du classement…</p></section>
 const me=rows.find(row=>row.is_me)
 return <div className="stack"><section className="hero-card"><div className="hero-copy"><p className="eyebrow light">Cette semaine</p><h1>Classement entre amis 🏆</h1><p>Le classement utilise uniquement l’XP gagnée depuis lundi par toi et tes amis acceptés.</p></div><div className="hero-orbit"><span>{me?.rank===1?'🥇':'🏆'}</span></div></section><section className="stats-grid"><article className="card score-card"><span>📍 Ta place</span><strong>#{me?.rank??'-'}</strong><small>sur {rows.length}</small></article><article className="card score-card"><span>⚡ XP semaine</span><strong>{me?.weekly_xp??0}</strong><small>{me?.weekly_answers??0} réponses</small></article><article className="card score-card"><span>🎓 Niveau</span><strong>{me?.level??1}</strong><small>{me?.xp_total??0} XP total</small></article></section><section className="card"><div className="section-heading"><div><p className="eyebrow">Amis</p><h2>Classement hebdomadaire</h2></div><Link className="text-link" to="/amis">Mes amis</Link></div><div className="people-list">{rows.map(row=><article className={`person-row ${row.is_me?'incoming':''}`} key={row.id}><div className="priority-rank">{row.rank}</div><div className="person-avatar">{row.avatar_url?<img src={row.avatar_url} alt=""/>:(row.first_name||row.username||'?').slice(0,1).toUpperCase()}</div><div className="person-copy"><strong>{row.is_me?'Moi':row.first_name||row.username}</strong><span>{row.username?`@${row.username} · `:''}niveau {row.level??1}</span></div><div className="subject-score"><strong>{row.weekly_xp}</strong><span>XP semaine</span></div></article>)}</div></section><section className="card muted-card"><p>Le classement repart à zéro chaque lundi. L’XP totale et les niveaux restent bien sûr conservés.</p></section></div>
}
