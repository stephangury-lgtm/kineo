import {Link,useLocation} from 'react-router-dom'
import {getCurrentProgram} from '../curriculum/programs'
import {learningSection} from './navigation'
export default function LearningNavigation(){
 const spain=getCurrentProgram().id==='kineo-es',active=learningSection(useLocation().pathname)
 const items=spain?[['/','☀','Hoy'],['/parcours','▦','Temario'],['/revision','✦','Repasar'],['/amis','♧','Comunidad'],['/progres','↗','Progreso']]:[['/','☀','Aujourd’hui'],['/parcours','▦','Parcours'],['/revision','✦','Réviser'],['/amis','♧','Communauté'],['/progres','↗','Progrès']]
 return <nav className="bottom-nav v5-navigation" aria-label={spain?'Navegación principal':'Navigation principale'}>{items.map(([to,icon,label])=><Link key={to} to={to} className={active===to?'active':''} aria-current={active===to?'page':undefined}><span className="nav-icon" aria-hidden="true">{icon}</span><span>{label}</span></Link>)}</nav>
}
