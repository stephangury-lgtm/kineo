import {useEffect,useRef,useState} from 'react'
import type {FriendChallenge} from '../services/challengeApi'
import {supabase} from '../lib/supabase'
import {notifyNotificationsUpdated} from '../services/notificationApi'
import ScoreCelebration from './ScoreCelebration'

type TieState={round:number;question:string;options:{id:string;text:string}[];my_answered:boolean;other_answered:boolean;round_closed:boolean;outcome:'waiting'|'win'|'loss'|'draw';my_correct:boolean|null;correct_answer:string|null;explanation:string|null;can_next:boolean}
type Props={duel:FriendChallenge;programId:string;isSpain:boolean;canRematch:boolean;initialTiebreak?:boolean;onClose:()=>void;onRematch:()=>void;onResolved:()=>void}
export default function DuelResultDialog({duel,programId,isSpain,canRematch,initialTiebreak=false,onClose,onRematch,onResolved}:Props){
 const dialog=useRef<HTMLDialogElement>(null)
 const [tie,setTie]=useState(initialTiebreak),[state,setState]=useState<TieState|null>(null),[answer,setAnswer]=useState(''),[busy,setBusy]=useState(false),[error,setError]=useState<string|null>(null)
 const lock=useRef(false),alive=useRef(true),ended=useRef(false)
 const t=(fr:string,es:string)=>isSpain?es:fr
 const mine=duel.direction==='sent'?duel.challenger_score:duel.challenged_score,other=duel.direction==='sent'?duel.challenged_score:duel.challenger_score
 const myId=duel.direction==='sent'?duel.challenger_id:duel.challenged_id
 const tied=mine!=null&&other!=null&&mine===other
 const outcome=duel.tiebreak_winner_id?(duel.tiebreak_winner_id===myId?'win':'loss'):mine==null||other==null?'waiting':mine>other?'win':mine<other?'loss':'draw'
 useEffect(()=>{alive.current=true;dialog.current?.showModal();return()=>{alive.current=false;dialog.current?.close()}},[])
 async function update(action:'read'|'answer'|'next'='read'){
  if(lock.current)return
  lock.current=true;if(action!=='read'||!state)setBusy(true);setError(null)
  try{
   const {data,error:rpcError}=await supabase.rpc('duel_tiebreak_v1',{p_challenge_id:duel.id,p_program_id:programId,p_round:action==='answer'?state?.round:null,p_answer:action==='answer'?answer:null,p_next:action==='next'})
   if(rpcError)throw rpcError
   if(!alive.current)return
   const value=data as TieState;setState(value);if(action==='next')setAnswer('')
   if(action!=='read'||value.round_closed)notifyNotificationsUpdated()
   if(value.outcome==='win'||value.outcome==='loss'){ended.current=true;onResolved()}
  }catch(e){if(alive.current)setError(e instanceof Error?e.message:String((e as {message?:string})?.message||t('Départage indisponible. Réessaie.','Desempate no disponible. Inténtalo de nuevo.')))}
  finally{lock.current=false;if(alive.current)setBusy(false)}
 }
 useEffect(()=>{if(!tie)return;void update();const timer=window.setInterval(()=>{if(document.visibilityState==='visible'&&!ended.current)void update()},10000);const refresh=()=>{if(!ended.current)void update()};window.addEventListener('focus',refresh);return()=>{window.clearInterval(timer);window.removeEventListener('focus',refresh)}},[tie])
 return <dialog ref={dialog} className="duel-result-dialog" aria-labelledby="duel-result-title" onCancel={e=>{if(busy)e.preventDefault();else onClose()}}>
  <header><h2 id="duel-result-title">{tie?t('Mort subite ⚡','Desempate ⚡'):outcome==='win'?t('Victoire !','¡Victoria!'):outcome==='loss'?t('Défi terminé','Duelo terminado'):t('Égalité !','¡Empate!')}</h2><button className="secondary-button compact-button" onClick={onClose} disabled={busy}>{t('Fermer','Cerrar')}</button></header>
  {!tie?<><ScoreCelebration score={mine??0} outcome={outcome} isSpain={isSpain}/><p className="duel-result-scores">{t('Toi','Tú')} : {mine??'–'} % · {duel.opponent.first_name||duel.opponent.username} : {other??'–'} %{duel.tiebreak_winner_id&&<><br/>{t('Départage remporté à la manche','Desempate decidido en la ronda')} {duel.tiebreak_round}</>}</p><footer>{tied&&!duel.tiebreak_winner_id&&canRematch&&<button className="primary-button" onClick={()=>setTie(true)}>{t('Mort subite · 1 question','Desempate · 1 pregunta')}</button>}<button className="secondary-button" onClick={onRematch} disabled={!canRematch}>{t('Lancer la revanche','Pedir revancha')}</button></footer></>:<>
   <p>{t('La même question pour tous les deux, chacun à son rythme. Une erreur face à une bonne réponse tranche le duel. Si vos réponses ne vous départagent pas, une nouvelle manche est proposée.','La misma pregunta para ambos, cada uno a su ritmo. Una respuesta incorrecta frente a una correcta decide el duelo. Si seguís empatados, se propone otra ronda.')}</p>
   {!state&&!error&&<p role="status">{t('Préparation…','Preparando…')}</p>}
   {state&&<section aria-label={t('Manche de départage','Ronda de desempate')}><p className="eyebrow">{t('Manche','Ronda')} {state.round}</p>{!state.round_closed?<><h3>{state.question}</h3>{state.my_answered?<p role="status">{t('Ta réponse est enregistrée. Tu peux revenir plus tard : ton ami joue quand il veut.','Tu respuesta está guardada. Puedes volver más tarde: tu amigo juega cuando quiera.')}</p>:<><div className="answers">{state.options.map(option=><button type="button" className={`answer ${answer===option.id?'selected':''}`} key={option.id} disabled={busy} onClick={()=>setAnswer(option.id)}>{option.text}</button>)}</div><button className="primary-button wide" disabled={busy||!answer} onClick={()=>void update('answer')}>{t('Valider ma réponse','Validar mi respuesta')}</button></>}</>:<><ScoreCelebration score={state.my_correct?100:0} outcome={state.outcome} isSpain={isSpain}/><p>{state.outcome==='win'?t('Tu remportes le départage !','¡Ganas el desempate!'):state.outcome==='loss'?t('Ton ami remporte le départage. Une revanche ?','Tu amigo gana el desempate. ¿Revancha?'):t('Toujours à égalité : on continue ?','Seguís empatados: ¿otra ronda?')}</p>{state.correct_answer&&<p>{t('Bonne réponse','Respuesta correcta')} : {state.correct_answer}</p>}{state.explanation&&<p>{state.explanation}</p>}<footer>{state.can_next&&<button className="primary-button" disabled={busy} onClick={()=>void update('next')}>{t('Question suivante pour vous départager','Siguiente pregunta para desempatar')}</button>}<button className="secondary-button" onClick={onRematch} disabled={!canRematch||busy}>{t('Lancer la revanche','Pedir revancha')}</button></footer></>}</section>}
   {error&&<p role="alert">{error}<button className="text-link" disabled={busy} onClick={()=>void update()}>{t('Réessayer','Reintentar')}</button></p>}
  </>}
 </dialog>
}
