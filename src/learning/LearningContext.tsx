import {Link,useLocation} from 'react-router-dom'
import {useInterfaceVersion} from './InterfaceVersion'
import {getCurrentProgram} from '../curriculum/programs'
export default function LearningContext(){
 const {v5}=useInterfaceVersion(),{pathname}=useLocation(),program=getCurrentProgram(),spain=program.id==='kineo-es'
 if(!v5)return null
 const course=['/lesson/','/cours/','/document/'].some(prefix=>pathname.startsWith(prefix))
 const review=pathname.startsWith('/session/')
 if(!course&&!review&&pathname!=='/parcours'&&pathname!=='/revision'&&pathname!=='/amis'&&pathname!=='/profil')return null
 return <div className="v5-context"><Link to={review?'/progres':'/'}>{review?(spain?'← Mi progreso':'← Mes progrès'):(spain?'← Hoy':'← Aujourd’hui')}</Link>{course&&<Link to="/parcours">{spain?'Mi temario':'Mon parcours'}</Link>}{(pathname==='/parcours'||course)&&program.id==='kineo-fr'&&<Link to="/bibliotheque">Mes cours et mes notes</Link>}{pathname==='/revision'&&<span>{spain?'Elige un objetivo de práctica.':'Choisis ici un objectif d’entraînement.'}</span>}{pathname==='/amis'&&<Link to="/classement">{spain?'Clasificación':'Classement entre collègues'}</Link>}</div>
}
