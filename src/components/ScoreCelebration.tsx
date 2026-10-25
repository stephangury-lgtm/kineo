import {useEffect,useState,type CSSProperties} from 'react'
import './ScoreCelebration.css'

type Props={score:number;outcome?:'win'|'loss'|'draw'|'waiting';isSpain?:boolean}
export default function ScoreCelebration({score,outcome,isSpain=false}:Props){
 const percent=Number.isFinite(score)?Math.min(100,Math.max(0,Math.round(score))):0
 const perfect=percent===100,celebrate=perfect||outcome==='win'
 const [showConfetti,setShowConfetti]=useState(celebrate)
 useEffect(()=>{setShowConfetti(celebrate);if(!celebrate)return;const timer=window.setTimeout(()=>setShowConfetti(false),2800);return()=>window.clearTimeout(timer)},[celebrate])
 const message=perfect?(isSpain?'¡Pleno de aciertos! Tu esfuerzo da sus frutos.':'Sans-faute ! Ton travail porte ses fruits.'):outcome==='win'?(isSpain?'¡Enhorabuena! Has ganado este duelo.':'Félicitations, tu remportes ce duel !'):outcome==='draw'?(isSpain?'¡Igualdad! ¿Una pregunta para desempatar?':'Égalité ! Une question pour vous départager ?'):outcome==='loss'?(isSpain?'Cada duelo te hace progresar. ¡La revancha te espera!':'Chaque duel te fait progresser. La revanche t’attend !'):null
 return <div className="score-celebration" data-celebration={perfect?'perfect':outcome==='win'?'victory':'progress'}>
  {celebrate&&showConfetti&&<div className="score-confetti" aria-hidden="true">{Array.from({length:32},(_,i)=><i key={i} style={{'--x':`${(i*37)%100}%`,'--delay':`${(i%7)*.07}s`,'--turn':`${180+i*43}deg`,'--colour':['#14b8a6','#fbbf24','#f97316','#8b5cf6'][i%4]} as CSSProperties}/>)}</div>}
  <div className="completion-score score-celebration__ring" role="progressbar" aria-label={isSpain?'Puntuación':'Score'} aria-valuemin={0} aria-valuemax={100} aria-valuenow={percent} style={{background:`conic-gradient(var(--program-primary,var(--brand)) ${percent}%, var(--program-soft,#e4eeec) ${percent}%)`}}><span>{percent}%</span></div>
  {message&&<p className="score-celebration__message" role="status">{celebrate&&<span aria-hidden="true">{perfect?'🎯':'🏆'} </span>}{message}</p>}
 </div>
}
