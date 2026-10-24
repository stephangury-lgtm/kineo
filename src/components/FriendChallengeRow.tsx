import type { FriendChallenge } from '../services/challengeApi'

type Props={item:FriendChallenge;isSpain:boolean;isKineoFrance:boolean;busy:boolean;onPlay:(id:string)=>void;onRespond:(id:string,accept:boolean)=>void;onCancel:(id:string)=>void}
export default function FriendChallengeRow({item,isSpain,isKineoFrance,busy,onPlay,onRespond,onCancel}:Props){
 const awaitingMe=item.direction==='received'&&item.status==='pending'
 const sentPending=item.direction==='sent'&&item.status==='pending'
 const waiting=item.has_played&&!item.opponent_has_played
 const playable=!item.has_played&&(item.status==='accepted'||item.status==='in_progress'||sentPending)
 const name=item.opponent.first_name||item.opponent.username||'Ami'
 const scope=!isKineoFrance&&item.level_code?` · ${item.level_code}`:''
 const status=waiting?(isSpain?'Tu puntuación está guardada · tu amigo jugará más tarde':'Ton score est enregistré · ton ami jouera plus tard'):awaitingMe?(isSpain?'Te reta a 10 preguntas · juega cuando quieras':'Te défie sur 10 questions · joue quand tu veux'):sentPending?(isSpain?'Reto enviado · ya puedes jugar':'Défi envoyé · tu peux déjà jouer'):(isSpain?'Mismo cuestionario · cada uno a su ritmo':'Même quiz · chacun à son rythme')
 return <article className="person-row challenge-row"><div className="person-avatar duel-avatar">{item.opponent.avatar_url?<img src={item.opponent.avatar_url} alt=""/>:name.slice(0,1).toUpperCase()}</div><div className="person-copy"><strong>{name}</strong><span>{status}{scope}</span></div><div className="friend-actions">
  {awaitingMe?<><button className="primary-button compact-button" onClick={()=>onRespond(item.id,true)} disabled={busy}>{isSpain?'Aceptar':'Accepter'}</button><button className="secondary-button compact-button" onClick={()=>onRespond(item.id,false)} disabled={busy}>{isSpain?'Rechazar':'Refuser'}</button></>:<>
   {playable&&<button className="primary-button compact-button" onClick={()=>onPlay(item.id)} disabled={busy}>{sentPending?(isSpain?'Jugar ahora':'Jouer maintenant'):(isSpain?'Jugar':'Jouer')}</button>}
   {waiting&&<span className="pending-chip">{isSpain?'Resultado pendiente':'Résultat en attente'}</span>}
   {sentPending&&<button className="text-link" onClick={()=>onCancel(item.id)} disabled={busy}>{isSpain?'Cancelar':'Annuler'}</button>}
  </>}
 </div></article>
}
