import { Link } from 'react-router-dom'

export default function NotFoundPage(){
 return <div className="stack"><section className="card centered"><div className="completion-icon">🧭</div><p className="eyebrow">Page introuvable</p><h1>Cette page n’existe plus</h1><p>Reviens à ton tableau de bord ou reprends directement une session de révision.</p><div className="completion-actions"><Link className="primary-button" to="/">Accueil</Link><Link className="secondary-button" to="/revision">Réviser</Link></div></section></div>
}
