import {type ReactNode} from 'react'
import {Link} from 'react-router-dom'
import {getCurrentProgram} from '../curriculum/programs'
import {getGamificationSummaryV2} from '../services/kineoApi'
import {useReadResource} from './useReadResource'
export default function RitualFrame({children,complete=false}:{children:ReactNode;complete?:boolean}){
 const program=getCurrentProgram(),spain=program.id==='kineo-es',game=useReadResource(getGamificationSummaryV2,program.id)
 return <div className="stack learning-v5 daily-ritual">
  <header className="ritual-welcome"><p className="eyebrow">{program.shortName} · {spain?'Hoy':'Aujourd’hui'}</p><h1>{spain?'Tu cita diaria con el progreso.':'Ton rendez-vous avec les progrès.'}</h1><p>{spain?'Un pequeño paso al día, a tu ritmo.':'Un petit pas chaque jour, à ton rythme.'}</p></header>
  <section className={'v5-next-action ritual-hero'+(complete?' ritual-complete':'')} aria-label={spain?'Mi próxima acción':'Ma prochaine action'}><div className="ritual-time">{complete?'✓':spain?'Sesión corta · unos 8–10 min':'Séance courte · environ 8–10 min'}</div>{children}</section>
  <section className="card ritual-consistency"><div className="section-heading"><h2>{spain?'Mi constancia':'Ma régularité'}</h2>{game.data&&<Link className="header-streak-badge" to="/progres">🔥 {game.data.streak.current} {spain?'días':'jours'}</Link>}</div><p>{complete?(spain?'Sesión terminada. Puedes parar por hoy.':'Séance terminée. Tu peux t’arrêter pour aujourd’hui.'):(spain?'Cada sesión cuenta. Tu próximo paso está listo.':'Chaque séance compte. Ta prochaine action est prête.')}</p><Link className="text-link" to="/progres">{spain?'Ver resultados y logros →':'Voir mes résultats et mes badges →'}</Link></section>
  <div className="ritual-shortcuts"><Link to="/parcours"><span aria-hidden="true">▦</span><span><strong>{spain?'Mis cursos':'Mes cours'}</strong><small>{spain?'Materias, capítulos y PDF':'Matières, chapitres et PDF'}</small></span><span aria-hidden="true">→</span></Link><Link to="/revision"><span aria-hidden="true">✦</span><span><strong>{spain?'Repasar libremente':'Réviser librement'}</strong><small>{spain?'Elegir un objetivo de práctica':'Choisir un objectif d’entraînement'}</small></span><span aria-hidden="true">→</span></Link></div>
 </div>
}
