import type { FriendChallenge } from '../services/challengeApi'
import { getDuelRivalries } from '../services/duelStats'

type Props = { challenges: FriendChallenge[]; isSpain: boolean; onChallenge: (id:string)=>void; canChallenge: (id:string)=>boolean; busy: boolean }

export default function DuelHeadToHead({challenges,isSpain,onChallenge,canChallenge,busy}:Props) {
 const rows=getDuelRivalries(challenges)
 if(!rows.length)return null
 const totals=rows.reduce((sum,row)=>({duels:sum.duels+row.duels,wins:sum.wins+row.wins,losses:sum.losses+row.losses,draws:sum.draws+row.draws}),{duels:0,wins:0,losses:0,draws:0})
 return <section className="card rivalry-card">
  <div className="section-heading"><div><p className="eyebrow">{isSpain?'Cara a cara':'Face-à-face'}</p><h2>{isSpain?'Tus rivalidades':'Tes rivalités'}</h2></div></div>
  <p>{totals.duels} {isSpain?'duelos terminados':'duels terminés'} · {totals.wins} 🏆 · {totals.losses} {isSpain?'derrotas':'défaites'} · {totals.draws} {isSpain?'empates':'égalités'}</p>
  <p className="curriculum-empty">{isSpain?'Balance de todos los retos terminados de este programa. Los retos pendientes o cancelados no cuentan.':'Bilan de tous les défis terminés dans ce cursus. Les défis en attente ou annulés ne comptent pas.'}</p>
  <div className="people-list">{rows.map(row=>{
   const name=row.opponent.first_name||row.opponent.username||(isSpain?'Rival':'Adversaire')
   const leader=row.wins>row.losses?(isSpain?'Vas por delante':'Tu mènes'):row.wins<row.losses?(isSpain?`${name} va por delante`:`${name} mène`):(isSpain?'Empate':'À égalité')
   const active=challenges.some(c=>c.opponent.id===row.opponent.id&&!['completed','declined','cancelled'].includes(c.status))
   return <article className="duel-result" key={row.opponent.id}>
    <div><strong>⚔️ {isSpain?'Tú contra':'Toi contre'} {name}</strong>
     <span>{row.duels} {isSpain?'duelos':'duels'} · {leader}</span>
     <span>{row.wins} {isSpain?'victorias':'victoires'} · {row.losses} {isSpain?'derrotas':'défaites'} · {row.draws} {isSpain?'empates':'égalités'}</span>
     <span>{isSpain?'Últimos resultados':'Derniers résultats'} : {row.recent.slice(0,5).map((value,i)=><b key={i} style={{marginRight:6}} title={value==='W'?(isSpain?'Victoria':'Victoire'):value==='L'?(isSpain?'Derrota':'Défaite'):(isSpain?'Empate':'Égalité')}>{value==='W'?'🏆':value==='L'?'●':'🤝'}</b>)}</span>
    </div>
    <div className="rivalry-actions"><div className="duel-score" aria-label={isSpain?'Victorias tuyas y de tu rival':'Victoires de toi et de ton adversaire'}><strong>{row.wins}</strong><span>—</span><strong>{row.losses}</strong></div>
     <button className="primary-button compact-button" disabled={busy||active||!canChallenge(row.opponent.id)} onClick={()=>onChallenge(row.opponent.id)}>{active?(isSpain?'Reto en curso':'Défi en cours'):(isSpain?'Revancha':'Revanche')}</button>
    </div>
   </article>
  })}</div>
 </section>
}
