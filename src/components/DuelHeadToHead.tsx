import type { FriendChallenge } from '../services/challengeApi'

type Props={challenges:FriendChallenge[]}

type Rivalry={
 opponent:FriendChallenge['opponent']
 duels:number
 wins:number
 losses:number
 draws:number
 myTotal:number
 opponentTotal:number
 recent:Array<'W'|'L'|'D'>
}

export default function DuelHeadToHead({challenges}:Props){
 const completed=challenges.filter(item=>item.status==='completed'&&item.challenger_score!=null&&item.challenged_score!=null)
 const rivalries=new Map<string,Rivalry>()
 for(const item of completed){
  const mine=item.direction==='sent'?item.challenger_score!:item.challenged_score!
  const other=item.direction==='sent'?item.challenged_score!:item.challenger_score!
  const key=item.opponent.id
  const current=rivalries.get(key)??{opponent:item.opponent,duels:0,wins:0,losses:0,draws:0,myTotal:0,opponentTotal:0,recent:[]}
  current.duels+=1
  current.myTotal+=mine
  current.opponentTotal+=other
  if(mine>other){current.wins+=1;current.recent.push('W')}
  else if(mine<other){current.losses+=1;current.recent.push('L')}
  else{current.draws+=1;current.recent.push('D')}
  rivalries.set(key,current)
 }
 const rows=[...rivalries.values()].filter(row=>row.duels>=2).sort((a,b)=>b.duels-a.duels||b.wins-a.wins)
 if(rows.length===0)return null
 return <section className="card">
  <div className="section-heading"><div><p className="eyebrow">Face-à-face</p><h2>Vos duels au fil du temps</h2></div></div>
  <p className="curriculum-empty">Le bilan cumule uniquement les défis terminés dans le cursus actuellement ouvert.</p>
  <div className="people-list">{rows.map(row=>{
   const name=row.opponent.first_name||row.opponent.username||'Adversaire'
   const leader=row.wins>row.losses?'Tu mènes':row.wins<row.losses?`${name} mène`:'Égalité parfaite'
   return <article className="duel-result" key={row.opponent.id}>
    <div>
     <strong>⚔️ Toi vs {name} · {row.duels} duels</strong>
     <span>{leader} · {row.wins} victoire{row.wins!==1?'s':''} · {row.losses} défaite{row.losses!==1?'s':''} · {row.draws} nul{row.draws!==1?'s':''}</span>
     <span>Série récente : {row.recent.slice(0,5).map((value,index)=><b key={`${value}-${index}`} title={value==='W'?'Victoire':value==='L'?'Défaite':'Égalité'} style={{marginRight:6}}>{value==='W'?'🏆':value==='L'?'●':'🤝'}</b>)}</span>
    </div>
    <div className="duel-score" title="Somme des scores de tous les duels terminés">
     <strong>{row.myTotal}</strong><span>—</span><strong>{row.opponentTotal}</strong>
    </div>
   </article>
  })}</div>
 </section>
}
