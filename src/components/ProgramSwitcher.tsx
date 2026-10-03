import { Link } from 'react-router-dom'
import { getCurrentProgram } from '../curriculum/programs'
export default function ProgramSwitcher(){const p=getCurrentProgram();return <Link className="program-switcher" to="/programmes" title="Changer de cursus"><span>{p.flag}</span><span><strong>{p.shortName}</strong><small>{p.country}</small></span><span aria-hidden="true">⌄</span></Link>}
