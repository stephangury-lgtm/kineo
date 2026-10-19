import {getFranceActiveSession,franceResumePath} from './france-resume'
import {useEffect} from 'react'
import RitualFrame from './RitualFrame'
import {useDailySession} from './DailySessionContext'
import {Link} from 'react-router-dom'
import {getCurrentProgram} from '../curriculum/programs'
import {getDashboardV2,getRevisionModeAvailabilityV1} from '../services/kineoApi'
import {useReadResource} from './useReadResource'

export default function TodayPage(){
 const program=getCurrentProgram(),spain=program.id==='kineo-es'
 return program.id==='kineo-fr'?<FranceToday/>:<CurriculumToday spain={spain}/>
}
function CurriculumToday({spain}:{spain:boolean}){
 const {state,storageAvailable}=useDailySession(),done=state.status==='completed',resume=state.status==='in_progress'
 return <RitualFrame complete={done}><p className="eyebrow">{spain?'Mi sesión de hoy':'Ma séance du jour'}</p><h2>{done?(spain?'Objetivo cumplido':'Objectif du jour accompli'):resume?(spain?'Continúa donde lo dejaste':'Reprends là où tu en étais'):(spain?'Consolida lo esencial':'Consolide tes connaissances')}</h2><p>{done?(spain?'Tus respuestas se han validado. Consulta tu progreso o vuelve mañana.':'Tes réponses ont été validées. Consulte tes progrès ou reviens demain.'):resume?`${state.answered} / ${state.total} ${spain?'preguntas respondidas':'questions traitées'}`:(spain?'Hasta 10 preguntas de tus niveles accesibles, sin elegir entre varios modos.':'Jusqu’à 10 questions de tes niveaux accessibles, sans choisir entre plusieurs modes.')}</p><Link className="primary-button" to={done?'/progres':'/ma-seance'}>{done?(spain?'Ver mi progreso':'Voir mes progrès'):resume?(spain?'Continuar mi sesión':'Reprendre ma séance'):(spain?'Empezar mi sesión':'Commencer ma séance')}</Link><Link className="ritual-course-link" to="/parcours">{spain?'Abrir mi temario':'Ouvrir mon parcours'}</Link><small>{storageAvailable?(spain?'Puedes recargar esta pestaña sin perder tu sesión. Se conserva durante el día en este dispositivo.':'Tu peux actualiser cet onglet sans perdre ta séance. Elle est conservée pour la journée sur cet appareil.'):(spain?'El almacenamiento del navegador no está disponible. Mantén esta pestaña abierta sin recargar.':'Le stockage du navigateur est indisponible. Garde cet onglet ouvert sans l’actualiser.')}</small></RitualFrame>
}
function FranceToday(){
 const {update,setResumePath}=useDailySession()
 const active=useReadResource(getFranceActiveSession,'kineo-fr')
 const modes=useReadResource(getRevisionModeAvailabilityV1,'kineo-fr')
 const dashboard=useReadResource(getDashboardV2,'kineo-fr')
 const session=active.data&&active.data.answered_count<active.data.question_count?active.data:null
 const dailyDone=dashboard.data?.daily?.completed===true||dashboard.data?.daily?.status==='completed'
 useEffect(()=>{if(!active.loading&&!active.error&&!dashboard.loading&&!dashboard.error){update({status:session?'in_progress':dailyDone?'completed':'ready',answered:session?.answered_count??0,total:session?.question_count??10});if(!session)setResumePath(null)}},[active.loading,active.error,dashboard.loading,dashboard.error,session,dailyDone,update,setResumePath])
 return <RitualFrame complete={dailyDone&&!session}>{active.loading?<p role="status">Recherche de ta séance en cours…</p>:active.error?<><h2>Vérifie ta séance avant de recommencer</h2><p role="alert">Impossible de vérifier si une séance est déjà en cours.</p><button className="secondary-button" onClick={active.retry}>Réessayer la reprise</button></>:session?<><p className="eyebrow">Ta séance en cours</p><h2>Reprends là où tu en étais</h2><p>{session.answered_count} questions traitées sur {session.question_count}.</p><Link className="primary-button" to={franceResumePath(session)}>Reprendre ma séance</Link></>:modes.loading?<p role="status">Recherche des exercices disponibles…</p>:modes.error?<><h2>Disponibilité à vérifier</h2><p role="alert">Les exercices ne peuvent pas être vérifiés pour le moment.</p><button className="secondary-button" onClick={modes.retry}>Réessayer les exercices</button></>:!modes.data?.total_questions?<><h2>Les questions de ton niveau sont en préparation</h2><p>Consulte les supports actuellement disponibles dans ton parcours.</p><Link className="primary-button" to="/parcours">Voir mon parcours</Link></>:dailyDone?<><h2>Ton défi du jour est terminé</h2><p>Tu peux consulter tes progrès ou choisir un entraînement supplémentaire.</p><Link className="primary-button" to="/progres">Voir mes progrès</Link><p><Link to="/revision">Choisir un autre entraînement</Link></p></>:<><p className="eyebrow">Ta séance du jour</p><h2>Consolide tes connaissances</h2><p>Les questions disponibles sont sélectionnées pour ton niveau.</p><Link className="primary-button" to="/ma-seance">Commencer ma séance</Link></>}</RitualFrame>
}
