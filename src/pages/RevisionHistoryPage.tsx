import {useEffect,useState} from 'react'
import {useNavigate} from 'react-router-dom'
import {getRecentRevisionSessionsV1,startRevisionSessionReplayV1,type RevisionHistoryItem} from '../services/kineoApi'
import './StatisticsPage.css'
const modeNames:Record<string,string>={smart:'Révision intelligente',visual:'Anatomie visuelle',exam:'Examen blanc',daily:'Défi du jour',clinical_case:'Cas clinique',matching:'Associations',mcq:'QCM',true_false:'Vrai / Faux',fill_blank:'Texte à trous',translation:'Traduction',mix:'Révision ciblée',weak:'Mes points faibles',replay:'Session refaite',subject:'Révision par matière',lesson:'Quiz de leçon',challenge:'Défi entre amis'}
export default function RevisionHistoryPage(){
 const navigate=useNavigate()
 const [items,setItems]=useState<RevisionHistoryItem[]>([])
 const [busy,setBusy]=useState<string|null>(null)
 const [error,setError]=useState('')
 useEffect(()=>{getRecentRevisionSessionsV1(30).then(setItems).catch(e=>setError(e instanceof Error?e.message:'Historique indisponible'))},[])
 async function replay(id:string){setBusy(id);setError('');try{const next=await startRevisionSessionReplayV1(id);navigate('/quiz?mode=replay&session='+encodeURIComponent(next))}catch(e){setError(e instanceof Error?e.message:'Session indisponible')}finally{setBusy(null)}}
 return <div className="stack stats-mobile"><header><h1>Mes dernières sessions</h1><p>Retrouve et refais tes révisions.</p></header>{error&&<p role="alert">{error}</p>}<section className="card session-history">{items.map(x=><article className="history-row" key={x.id}><div className="history-mode"><strong>{modeNames[x.mode]??'Révision'}</strong><small>{new Date(x.completed_at??x.started_at).toLocaleDateString('fr-FR')} · {x.score_percent}% · {x.question_count} questions</small></div><button type="button" className="session-replay-mini" disabled={busy!==null} onClick={()=>void replay(x.id)}>{busy===x.id?'…':'↻ Refaire'}</button></article>)}</section></div>
}
