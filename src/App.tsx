import { NavLink, Route, Routes } from 'react-router-dom'
import AuthGate from './auth/AuthGate'
import { supabase } from './lib/supabase'
import DashboardPage from './pages/DashboardPage'
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
            <Route path="/revision" element={<RevisionPage />} />
            <Route path="/stats" element={<StatisticsPage />} />
          </Routes>
        </main>

        <nav className="bottom-nav" aria-label="Navigation principale">
          <NavLink to="/" end>Accueil</NavLink>
          <NavLink to="/revision">Réviser</NavLink>
          <NavLink to="/stats">Stats</NavLink>
        </nav>
      </div>
    </AuthGate>
  )
}
