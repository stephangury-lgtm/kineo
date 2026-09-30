import { NavLink, Route, Routes } from 'react-router-dom'
import AuthGate from './auth/AuthGate'
import { supabase } from './lib/supabase'
import CurriculumPage from './pages/CurriculumPage'
import DashboardPage from './pages/DashboardPage'
import GamificationPage from './pages/GamificationPage'
import RevisionPage from './pages/RevisionPage'
import StatisticsPage from './pages/StatisticsPage'

export default function App() {
  return (
    <AuthGate>
      <div className="app-shell">
        <header className="topbar">
          <div>
            <strong className="brand">Kineo</strong>
            <span className="tagline">Réviser. Progresser. Retenir.</span>
          </div>
          <button className="ghost-button" onClick={() => supabase.auth.signOut()}>Déconnexion</button>
        </header>

        <main className="content">
          <Routes>
            <Route path="/" element={<DashboardPage />} />
            <Route path="/parcours" element={<CurriculumPage />} />
            <Route path="/revision" element={<RevisionPage />} />
            <Route path="/stats" element={<StatisticsPage />} />
            <Route path="/rewards" element={<GamificationPage />} />
          </Routes>
        </main>

        <nav className="bottom-nav" style={{ gridTemplateColumns: 'repeat(5, 1fr)' }} aria-label="Navigation principale">
          <NavLink to="/" end>Accueil</NavLink>
          <NavLink to="/parcours">Parcours</NavLink>
          <NavLink to="/revision">Réviser</NavLink>
          <NavLink to="/stats">Stats</NavLink>
          <NavLink to="/rewards">Badges</NavLink>
        </nav>
      </div>
    </AuthGate>
  )
}
