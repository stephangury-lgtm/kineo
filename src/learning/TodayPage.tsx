import {type ReactNode} from 'react'
import {Link} from 'react-router-dom'
import {getCurrentProgram} from '../curriculum/programs'
import {getActiveRevisionSessionV1,getDashboardV2,getRevisionModeAvailabilityV1} from '../services/kineoApi'
import {useReadResource} from './useReadResource'

export default function TodayPage(){
 const program=getCurrentProgram(),spain=program.id==='kineo-es'
 return program.id==='kineo-fr'?<FranceToday/>:<TodayFrame><h2>{spain?'Continúa tu temario':'Continue ton parcours'}</h2><p>{spain?'Elige un tema disponible para tu nivel.':'Retrouve les thèmes disponibles pour ton niveau et reprends ta prochaine notion.'}</p><Link className="primary-button" to="/parcours">{spain?'Abrir mi temario':'Ouvrir mon parcours'}</Link></TodayFrame>
}
function TodayFrame({children}:{children:ReactNode}){
 const program=getCurrentProgram(),spain=program.id==='kineo-es'
 return <div className="stack learning-v5"><section className="home-v4-welcome"><p className="eyebrow">{spain?'Hoy · tu espacio Leryko':'Aujourd’hui · ton espace Leryko'} · {program.shortName}</p><h1>{spain?'Tu próximo paso, claro':'Une prochaine étape claire'}</h1><p>{spain?'Consulta tus cursos y practica con los contenidos disponibles.':'Consulte tes cours et entraîne-toi avec les contenus disponibles.'}</p></section><section className="card v5-next-action" aria-label={spain?'Mi próxima acción':'Ma prochaine action'}>{children}</section><section className="card"><div className="section-heading"><div><p className="eyebrow">{spain?'Mi programa':'Ton programme'}</p><h2>{spain?'Cursos y temas':'Cours et chapitres'}</h2></div><Link className="secondary-button" to="/parcours">{spain?'Elegir un tema':'Choisir une notion'}</Link></div>{program.id==='kineo-fr'?<p><Link className="text-link" to="/bibliotheque">Retrouver mes supports et mes notes</Link></p>:<p>{spain?'Consulta los materiales disponibles en cada tema.':'Retrouve les supports disponibles dans chaque thème du parcours.'}</p>}</section><section className="card"><h2>{spain?'Mi constancia y mis logros':'Ma régularité et mes réussites'}</h2><Link className="text-link" to="/progres">{spain?'Ver mi racha, resultados y logros':'Voir ma flamme, mes résultats et mes badges'}</Link></section></div>
}
function FranceToday(){
 const active=useReadResource(getActiveRevisionSessionV1,'kineo-fr')
 const modes=useReadResource(getRevisionModeAvailabilityV1,'kineo-fr')
 const dashboard=useReadResource(getDashboardV2,'kineo-fr')
 const session=active.data&&active.data.answered_count<active.data.question_count?active.data:null
 const dailyDone=dashboard.data?.daily?.completed===true||dashboard.data?.daily?.status==='completed'
 return <TodayFrame>{active.loading?<p role="status">Recherche de ta séance en cours…</p>:active.error?<><h2>Vérifie ta séance avant de recommencer</h2><p role="alert">Impossible de vérifier si une séance est déjà en cours.</p><button className="secondary-button" onClick={active.retry}>Réessayer la reprise</button></>:session?<><p className="eyebrow">Ta séance en cours</p><h2>Reprends là où tu en étais</h2><p>{session.answered_count} questions traitées sur {session.question_count}.</p><Link className="primary-button" to={'/quiz?mode=resume&session='+encodeURIComponent(session.id)}>Reprendre ma séance</Link></>:modes.loading?<p role="status">Recherche des exercices disponibles…</p>:modes.error?<><h2>Disponibilité à vérifier</h2><p role="alert">Les exercices ne peuvent pas être vérifiés pour le moment.</p><button className="secondary-button" onClick={modes.retry}>Réessayer les exercices</button></>:!modes.data?.total_questions?<><h2>Les questions de ton niveau sont en préparation</h2><p>Consulte les supports actuellement disponibles dans ton parcours.</p><Link className="primary-button" to="/parcours">Voir mon parcours</Link></>:dailyDone?<><h2>Ton défi du jour est terminé</h2><p>Tu peux consulter tes progrès ou choisir un entraînement supplémentaire.</p><Link className="primary-button" to="/progres">Voir mes progrès</Link><p><Link to="/revision">Choisir un autre entraînement</Link></p></>:<><p className="eyebrow">Ta séance du jour</p><h2>Consolide tes connaissances</h2><p>Les questions disponibles sont sélectionnées pour ton niveau.</p><Link className="primary-button" to={dashboard.error||dashboard.loading?'/quiz':'/quiz?mode=daily'}>Commencer ma séance</Link></>}</TodayFrame>
}
