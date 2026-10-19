import {getFranceActiveSession,franceResumePath} from './france-resume'
import {Navigate} from 'react-router-dom'
import {getCurrentProgram} from '../curriculum/programs'
import {getDashboardV2} from '../services/kineoApi'
import {useReadResource} from './useReadResource'
import {useDailySession} from './DailySessionContext'
export default function DailySessionPage(){
 const {resumePath}=useDailySession()
 return getCurrentProgram().id==='kineo-fr'?(resumePath?<Navigate to={resumePath} replace/>:<FranceSession/>):<CurriculumSession/>
}
function CurriculumSession(){const {state}=useDailySession();return <Navigate to={state.status==='completed'?'/':'/fondamentaux?mode=mix&daily=1'} replace/>}
function FranceSession(){
 const active=useReadResource(getFranceActiveSession,'daily-entry'),dashboard=useReadResource(getDashboardV2,'daily-entry')
 if(active.loading)return <section className="card" role="status">Recherche de ta séance en cours…</section>
 if(active.error)return <section className="card"><h1>Ta séance reste à vérifier</h1><p>Réessaie avant de démarrer une nouvelle série.</p><button className="primary-button" onClick={active.retry}>Réessayer la reprise</button></section>
 const session=active.data
 if(session&&session.answered_count<session.question_count)return <Navigate to={franceResumePath(session)} replace/>
 if(dashboard.loading)return <section className="card" role="status">Préparation de ta séance du jour…</section>
 if(dashboard.error)return <section className="card"><h1>Disponibilité à vérifier</h1><button className="primary-button" onClick={dashboard.retry}>Réessayer</button></section>
 return <Navigate to={dashboard.data?.daily?.completed||dashboard.data?.daily?.status==='completed'?'/':'/quiz?mode=daily'} replace/>
}
