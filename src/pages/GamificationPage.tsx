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

  const level = summary.level
  const earned = badges.badges.filter((badge) => badge.earned)
  const locked = badges.badges.filter((badge) => !badge.earned)
  const progress = Math.round(earned.length / Math.max(1,badges.badges.length)*100)
  const categories = [{key:'regular',icon:'📅',name:isSpain?'Regularidad':'Régularité',test:/série|racha|jour|día|streak|regular/i},{key:'knowledge',icon:'🧠',name:isSpain?'Conocimientos':'Connaissances',test:/question|réponse|respuesta|anatom|expert|savoir|conocim/i},{key:'performance',icon:'🏆',name:isSpain?'Rendimiento':'Performance',test:/score|perfect|réuss|aciert|performance|xp/i},{key:'journey',icon:'📈',name:isSpain?'Recorrido':'Parcours',test:/niveau|nivel|parcours|étape|curso/i},{key:'challenges',icon:'🎯',name:isSpain?'Desafíos':'Défis',test:/défi|desaf|challenge|ami/i},{key:'special',icon:'⭐',name:isSpain?'Especial':'Spécial',test:/.*/}]
  const groups = categories.map(cat=>({...cat,items:badges.badges.filter(b=>{const text=getBadgeCopy(b,isSpain).name+' '+getBadgeCopy(b,isSpain).description;return cat.key==='special'? !categories.slice(0,5).some(other=>other.test.test(text)):cat.test.test(text)&&!categories.slice(0,categories.indexOf(cat)).some(other=>other.test.test(text))})}))

  return <div className="stack stats-mobile badge-dashboard">
    <header className="stats-page-head"><div><h1>{isSpain?'Mis logros':'Mes badges'}</h1><p>{isSpain?'¡Tus esfuerzos tienen recompensa!':'Tes efforts sont récompensés !'}</p></div><span className="profile-context">{getCurrentProgram().shortName}</span></header>
    <section className="badge-celebration"><div><span className="badge-kicker">✦ {isSpain?'Colección de logros':'Collection de badges'}</span><h2>{isSpain?'Cada paso cuenta.':'Chaque progrès compte.'}</h2><p>{isSpain?'Sigue aprendiendo y desbloquea nuevos logros.':'Continue à réviser et débloque de nouvelles récompenses.'}</p></div><span className="badge-hero-trophy" aria-hidden="true">🏆</span></section>
    <section className="card badge-overview"><div className="badge-progress-ring" style={{'--badge-progress':progress+'%'} as React.CSSProperties}><div><span>⭐</span><strong>{earned.length}</strong><small>/ {badges.badges.length}</small></div></div><div className="badge-overview-copy"><h2>{isSpain?'¡Sigue así!':'Continue comme ça !'}</h2><p>{isSpain?'Logros desbloqueados':'Badges débloqués'} : <strong>{earned.length}</strong> · {isSpain?'Por descubrir':'À découvrir'} : <strong>{locked.length}</strong></p><div className="progress-track"><div className="progress-fill" style={{width:progress+'%'}}/></div><small>{progress}% · {summary.xp_total} XP · {isSpain?'Racha':'Série'} {summary.streak.current} {isSpain?'días':'jours'}</small></div></section>
    <section className="badge-section"><div className="badge-section-head"><h2>{isSpain?'Mis logros por categoría':'Mes badges par catégorie'}</h2><span>{earned.length}/{badges.badges.length}</span></div><div className="badge-category-grid">{groups.map(g=><article className="badge-category-card" key={g.key}><span className={'badge-category-icon '+g.key}>{g.icon}</span><strong>{g.name}</strong><div className="badge-category-count"><strong>{g.items.filter(b=>b.earned).length} / {g.items.length}</strong><span>{isSpain?'obtenidos / disponibles':'acquis / disponibles'}</span><small>{g.items.length===0?(isSpain?'Ningún logro disponible':'Aucun badge disponible'):`${g.items.length-g.items.filter(b=>b.earned).length} ${isSpain?'por desbloquear':'à débloquer'}`}</small></div><div className="progress-track small"><div className="progress-fill" style={{width:(g.items.filter(b=>b.earned).length/Math.max(1,g.items.length)*100)+'%'}}/></div></article>)}</div></section>
    <section className="badge-section"><div className="badge-section-head"><h2>{isSpain?'Logros recientes':'Badges récents'}</h2><span>{earned.length} ✓</span></div>{earned.length?<div className="badge-showcase-grid">{earned.map(b=><article className="badge-showcase-card" key={b.id}><div className="badge-medal earned" aria-hidden="true"><span>{b.icon||'🏅'}</span></div><strong>{getBadgeCopy(b,isSpain).name}</strong><small>{getBadgeCopy(b,isSpain).description}</small><span className="badge-earned-label">{isSpain?'Desbloqueado':'Débloqué'}</span></article>)}</div>:<div className="card badge-empty">{isSpain?'¡Tu primera medalla te espera!':'Ta première médaille t’attend !'}</div>}</section>
    <details className="badge-section badge-locked-disclosure"><summary className="badge-section-head"><h2>{isSpain?'Próximos logros':'Prochains badges à débloquer'}</h2><span>{locked.length} ▾</span></summary><div className="badge-next-grid">{locked.map(b=><article className="badge-next-card" key={b.id}><div className="badge-medal locked" aria-hidden="true"><span>{b.icon||'🏅'}</span></div><div><strong>{getBadgeCopy(b,isSpain).name}</strong><small>{getBadgeCopy(b,isSpain).description}</small><div className="progress-track small"><div className="progress-fill" style={{width:Math.min(100,b.progress_percent)+'%'}}/></div><span className="badge-count">{b.current_value}/{b.target_value} · {b.progress_percent}%</span></div></article>)}</div></details>
  </div>
}
