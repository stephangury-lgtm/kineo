import { NavLink, Route, Routes } from 'react-router-dom'
import DashboardPage from './pages/DashboardPage'
import RevisionPage from './pages/RevisionPage'

export default function App() {
  return (
    <div className="app-shell">
      <header className="topbar">
        <div>
          <strong className="brand">Kineo</strong>
          <span className="tagline">Réviser. Progresser. Retenir.</span>
        </div>
      </header>

      <main className="content">
        <Routes>
          <Route path="/" element={<DashboardPage />} />
          <Route path="/revision" element={<RevisionPage />} />
        </Routes>
      </main>

      <nav className="bottom-nav" aria-label="Navigation principale">
        <NavLink to="/" end>Accueil</NavLink>
        <NavLink to="/revision">Réviser</NavLink>
      </nav>
    </div>
  )
}
