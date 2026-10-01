import { NavLink, Route, Routes } from 'react-router-dom'
import AuthGate from './auth/AuthGate'
import CurriculumPage from './pages/CurriculumPage'
import DashboardPage from './pages/DashboardPage'
import FriendsPage from './pages/FriendsPage'
import GamificationPage from './pages/GamificationPage'
import LessonPage from './pages/LessonPage'
import ProfilePage from './pages/ProfilePage'
import RevisionPage from './pages/RevisionPage'
import StatisticsPage from './pages/StatisticsPage'

const navItems = [
  { to: '/', label: 'Accueil', icon: '⌂', end: true },
  { to: '/parcours', label: 'Parcours', icon: '▦' },
  { to: '/revision', label: 'Réviser', icon: '✦' },
  { to: '/stats', label: 'Stats', icon: '↗' },
  { to: '/rewards', label: 'Badges', icon: '★' },
]

export default function App() {
  return (
    <AuthGate>
      <div className="app-shell">
        <header className="topbar">
          <div className="brand-lockup">
            <span className="brand-mark">K</span>
            <div><strong className="brand">Kineo</strong><span className="tagline">Réviser. Progresser. Retenir.</span></div>
          </div>
          <NavLink className="icon-button profile-button" aria-label="Mon profil" to="/profil">●</NavLink>
        </header>

        <main className="content">
          <Routes>
            <Route path="/" element={<DashboardPage />} />
            <Route path="/parcours" element={<CurriculumPage />} />
            <Route path="/lesson/:lessonId" element={<LessonPage />} />
            <Route path="/revision" element={<RevisionPage />} />
            <Route path="/stats" element={<StatisticsPage />} />
            <Route path="/rewards" element={<GamificationPage />} />
            <Route path="/profil" element={<ProfilePage />} />
            <Route path="/amis" element={<FriendsPage />} />
          </Routes>
        </main>

        <nav className="bottom-nav" aria-label="Navigation principale">
          {navItems.map((item) => <NavLink key={item.to} to={item.to} end={item.end}><span className="nav-icon" aria-hidden="true">{item.icon}</span><span>{item.label}</span></NavLink>)}
        </nav>
      </div>
    </AuthGate>
  )
}
