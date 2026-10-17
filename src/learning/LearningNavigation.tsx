import {Link,useLocation} from 'react-router-dom'
import {getCurrentProgram} from '../curriculum/programs'
import {learningSection} from './navigation'
import {useDailySession} from './DailySessionContext'
export default function LearningNavigation(){
 const spain=getCurrentProgram().id==='kineo-es',active=learningSection(useLocation().pathname)
 const {state}=useDailySession()
 const items=spain?[['/parcours','▦','Temario'],['/amis','♧','Amigos'],['/ma-seance','▶','Mi sesión'],['/progres','↗','Progreso'],['/profil','♙','Perfil']]:[['/parcours','▦','Parcours'],['/amis','♧','Amis'],['/ma-seance','▶','Ma séance'],['/progres','↗','Progrès'],['/profil','♙','Profil']]
 return <nav className="bottom-nav v5-navigation" aria-label={spain?'Navegación principal':'Navigation principale'}>{items.map(([to,icon,label])=><Link key={to} to={to} className={[active===to?'active':'',to==='/ma-seance'?'v5-daily-button':''].join(' ')} aria-current={active===to?'page':undefined}><span className="nav-icon" aria-hidden="true">{to==='/ma-seance'&&state.status==='completed'?'✓':icon}</span><span>{label}</span></Link>)}</nav>
}
