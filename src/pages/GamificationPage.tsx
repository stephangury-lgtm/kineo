import { useEffect, useState } from 'react'
import { getCurrentProgram } from '../curriculum/programs'
import { getBadgeCopy } from '../curriculum/gamificationCopy'
import {
  getBadgesV2,
  getGamificationSummaryV2,
  type BadgesV2,
  type GamificationSummaryV2,
} from '../services/kineoApi'

import './GamificationPage.css'

export default function GamificationPage() {
  const isSpain = getCurrentProgram().id === 'kineo-es'
  const [summary, setSummary] = useState<GamificationSummaryV2 | null>(null)
  const [badges, setBadges] = useState<BadgesV2 | null>(null)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    Promise.all([getGamificationSummaryV2(), getBadgesV2()])
      .then(([summaryData, badgeData]) => {
        setSummary(summaryData)
        setBadges(badgeData)
      })
      .catch((err: Error) => setError(err.message))
  }, [])

  if (error) return <section className="card"><h1>{isSpain?'Recompensas no disponibles':'Gamification indisponible'}</h1><p>{error}</p></section>
  if (!summary || !badges) return <section className="card skeleton-card"><p>{isSpain?'Cargando tus recompensas…':'Chargement de tes récompenses…'}</p></section>

  const isBadgeEarned = (badge: BadgesV2['badges'][number]) => badge.earned || (badge.target_value > 0 && badge.current_value >= badge.target_value)
  const earned = badges.badges.filter(isBadgeEarned)
  const locked = badges.badges.filter((badge) => !isBadgeEarned(badge))
  const progress = Math.round(earned.length / Math.max(1,badges.badges.length)*100)
  // Classify the complete catalogue (earned AND locked) from stable achievement rules.
  // Names and translations are only a fallback, never the primary grouping key.
  const categories = [{key:'regular',icon:'📅',name:isSpain?'Regularidad':'Régularité'},{key:'knowledge',icon:'🧠',name:isSpain?'Conocimientos':'Connaissances'},{key:'performance',icon:'🏆',name:isSpain?'Rendimiento':'Performance'},{key:'journey',icon:'📈',name:isSpain?'Recorrido':'Parcours'},{key:'challenges',icon:'🎯',name:isSpain?'Desafíos':'Défis'},{key:'special',icon:'⭐',name:isSpain?'Especial':'Spécial'}]
  const categoryForBadge = (badge: BadgesV2['badges'][number]) => {
    const rule = badge.condition_type.toLowerCase()
    if (/streak|daily_completed|consecutive|regular/.test(rule)) return 'regular'
    if (/correct_answers|question|anatom|knowledge/.test(rule)) return 'knowledge'
    if (/daily_perfect|perfect|score|accuracy|performance|xp/.test(rule)) return 'performance'
    if (/quiz_completed|lesson|course|level|year|journey|curriculum/.test(rule)) return 'journey'
    if (/friends_added/.test(rule)) return 'special'
    if (/challenge|duel|friend|social/.test(rule)) return 'challenges'
    const text = (badge.name + ' ' + badge.description).toLowerCase()
    if (/série|racha|jour|día|streak|regular/.test(text)) return 'regular'
    if (/question|réponse|respuesta|anatom|expert|savoir|conocim/.test(text)) return 'knowledge'
    if (/score|perfect|réuss|aciert|performance|xp/.test(text)) return 'performance'
    if (/niveau|nivel|parcours|étape|curso|quiz/.test(text)) return 'journey'
    if (/défi|desaf|challenge|ami/.test(text)) return 'challenges'
    return 'special'
  }
  const groups = categories.map(cat=>({...cat,items:badges.badges.filter(b=>categoryForBadge(b)===cat.key)}))
  const countedTotal = groups.reduce((sum,group)=>sum+group.items.length,0)
  const countedEarned = groups.reduce((sum,group)=>sum+group.items.filter(b=>b.earned).length,0)

  return <div className="stack stats-mobile badge-dashboard">
    <header className="stats-page-head"><div><h1>{isSpain?'Mis logros':'Mes badges'}</h1><p>{isSpain?'¡Tus esfuerzos tienen recompensa!':'Tes efforts sont récompensés !'}</p></div><span className="profile-context">{getCurrentProgram().shortName}</span></header>
    <section className="badge-celebration"><div><span className="badge-kicker">✦ {isSpain?'Colección de logros':'Collection de badges'}</span><h2>{isSpain?'Cada paso cuenta.':'Chaque progrès compte.'}</h2><p>{isSpain?'Sigue aprendiendo y desbloquea nuevos logros.':'Continue à réviser et débloque de nouvelles récompenses.'}</p></div><span className="badge-hero-trophy" aria-hidden="true">🏆</span></section>
    <section className="card badge-overview"><div className="badge-progress-ring" style={{'--badge-progress':progress+'%'} as React.CSSProperties}><div><span>⭐</span><strong>{earned.length}</strong><small>/ {badges.badges.length}</small></div></div><div className="badge-overview-copy"><h2>{isSpain?'¡Sigue así!':'Continue comme ça !'}</h2><p>{isSpain?'Logros desbloqueados':'Badges débloqués'} : <strong>{earned.length}</strong> · {isSpain?'Por descubrir':'À découvrir'} : <strong>{locked.length}</strong></p><div className="progress-track"><div className="progress-fill" style={{width:progress+'%'}}/></div><small>{progress}% · {summary.xp_total} XP · {isSpain?'Racha':'Série'} {summary.streak.current} {isSpain?'días':'jours'}</small></div></section>
    <section className="badge-section"><div className="badge-section-head"><h2>{isSpain?'Mis logros por categoría':'Mes badges par catégorie'}</h2><span>{countedEarned}/{countedTotal}</span></div><div className="badge-category-grid">{groups.map(g=><details className="badge-category-card badge-category-expandable" key={g.key}><summary className="badge-category-toggle"><span className={'badge-category-icon '+g.key}>{g.icon}</span><strong>{g.name}</strong><span className="badge-category-count"><strong>{g.items.filter(isBadgeEarned).length} / {g.items.length}</strong><span>{isSpain?'obtenidos / disponibles':'acquis / disponibles'}</span><small>{g.items.length-g.items.filter(isBadgeEarned).length} {isSpain?'por desbloquear':'à débloquer'}</small></span><span className="badge-category-chevron" aria-hidden="true">⌄</span><span className="progress-track small"><span className="progress-fill" style={{width:(g.items.filter(isBadgeEarned).length/Math.max(1,g.items.length)*100)+'%'}}/></span></summary><div className="badge-category-details">{g.items.length===0?<p>{isSpain?'Ningún logro disponible':'Aucun badge disponible'}</p>:g.items.slice().sort((a,b)=>Number(isBadgeEarned(b))-Number(isBadgeEarned(a))).map(b=><div className="badge-category-detail" key={b.id}><span className={'badge-medal '+(isBadgeEarned(b)?'earned':'locked')}>{b.icon||'🏅'}</span><div><strong>{getBadgeCopy(b,isSpain).name}</strong><small>{getBadgeCopy(b,isSpain).description}</small><span className="badge-count">{isBadgeEarned(b)?(isSpain?'✓ Obtenido':'✓ Acquis'):`${b.current_value}/${b.target_value} · ${b.progress_percent}%`}</span></div></div>)}</div></details>)}</div></section>
    <section className="badge-section"><div className="badge-section-head"><h2>{isSpain?'Logros recientes':'Badges récents'}</h2><span>{earned.length} ✓</span></div>{earned.length?<div className="badge-showcase-grid">{earned.map(b=><article className="badge-showcase-card" key={b.id}><div className="badge-medal earned" aria-hidden="true"><span>{b.icon||'🏅'}</span></div><strong>{getBadgeCopy(b,isSpain).name}</strong><small>{getBadgeCopy(b,isSpain).description}</small><span className="badge-earned-label">{isSpain?'Desbloqueado':'Débloqué'}</span></article>)}</div>:<div className="card badge-empty">{isSpain?'¡Tu primera medalla te espera!':'Ta première médaille t’attend !'}</div>}</section>
    <details className="badge-section badge-locked-disclosure"><summary className="badge-section-head"><h2>{isSpain?'Próximos logros':'Prochains badges à débloquer'}</h2><span>{locked.length} ▾</span></summary><div className="badge-next-grid">{locked.map(b=><article className="badge-next-card" key={b.id}><div className="badge-medal locked" aria-hidden="true"><span>{b.icon||'🏅'}</span></div><div><strong>{getBadgeCopy(b,isSpain).name}</strong><small>{getBadgeCopy(b,isSpain).description}</small><div className="progress-track small"><div className="progress-fill" style={{width:Math.min(100,b.progress_percent)+'%'}}/></div><span className="badge-count">{b.current_value}/{b.target_value} · {b.progress_percent}%</span></div></article>)}</div></details>
  </div>
}
