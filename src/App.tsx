import { NavLink, Navigate, Route, Routes } from 'react-router-dom'
import AdminGate from './auth/AdminGate'
import AuthGate from './auth/AuthGate'
import RevisionContentGate from './auth/RevisionContentGate'
import RevisionModeGate from './auth/RevisionModeGate'
import AppVersionBadge from './components/AppVersionBadge'
import ExamTimerBar from './components/ExamTimerBar'
import FeedbackButton from './components/FeedbackButton'
import HeaderProfileButton from './components/HeaderProfileButton'
import NotificationBell from './components/NotificationBell'
import OfflineStatus from './components/OfflineStatus'
import { getCurrentProgram } from './curriculum/programs'
import AdminPage from './pages/AdminPage'
import CurriculumChallengePage from './pages/CurriculumChallengePage'
import CurriculumPage from './pages/CurriculumPage'
import CurriculumTopicPage from './pages/CurriculumTopicPage'
import DashboardPage from './pages/DashboardPage'
import FriendsPage from './pages/FriendsPage'
import GamificationPage from './pages/GamificationPage'
import LeaderboardPage from './pages/LeaderboardPage'
import LessonPage from './pages/LessonPage'
import LibraryPage from './pages/LibraryPage'
import MockExamPage from './pages/MockExamPage'
import NotFoundPage from './pages/NotFoundPage'
import NotificationsPage from './pages/NotificationsPage'
import ProfilePage from './pages/ProfilePage'
import ProgramLandingPage from './pages/ProgramLandingPage'
import RevisionPage from './pages/RevisionPage'
import './pages/RevisionPage.css'
import SessionReviewPage from './pages/SessionReviewPage'
import StatisticsPage from './pages/StatisticsPage'
import SubjectRevisionPage from './pages/SubjectRevisionPage'
import VisualAdminPage from './pages/VisualAdminPage'
import VisualRevisionPage from './pages/VisualRevisionPage'
import WeakRevisionPage from './pages/WeakRevisionPage'
import './curriculum.css'

export default function App(){
 const program=getCurrentProgram(),isKineoFrance=program.id==='kineo-fr',isSpain=program.id==='kineo-es'
 const navItems=isKineoFrance
  ?[{to:'/',label:'Accueil',icon:'⌂',end:true},{to:'/parcours',label:'Parcours',icon:'▦'},{to:'/revision',label:'Réviser',icon:'✦'},{to:'/stats',label:'Stats',icon:'↗'},{to:'/rewards',label:'Badges',icon:'★'}]
  :isSpain
   ?[{to:'/',label:'Inicio',icon:'⌂',end:true},{to:'/parcours',label:'Temario',icon:'▦'},{to:'/amis',label:'Amigos',icon:'⚔'},{to:'/rewards',label:'Logros',icon:'★'},{to:'/profil',label:'Perfil',icon:'●'}]
   :[{to:'/',label:'Accueil',icon:'⌂',end:true},{to:'/parcours',label:'Cursus',icon:'▦'},{to:'/amis',label:'Amis',icon:'⚔'},{to:'/rewards',label:'Badges',icon:'★'},{to:'/profil',label:'Profil',icon:'●'}]
 const curriculumHome=<ProgramLandingPage/>
 return <AuthGate><div className="app-shell"><OfflineStatus/><header className="topbar"><div className="brand-lockup"><span className="brand-mark">{program.accent}</span><div><strong className="brand">{program.shortName}</strong><span className="tagline">{isKineoFrance?'Réviser. Progresser. Retenir.':program.subtitle}</span><span className="brand-platform">{isSpain?'Plataforma salud · tu grado':'Plateforme santé · ton cursus'}</span></div><AppVersionBadge/></div><div className="topbar-actions"><NotificationBell/><HeaderProfileButton/></div></header><ExamTimerBar/><main className="content"><Routes><Route path="/" element={isKineoFrance?<DashboardPage/>:curriculumHome}/><Route path="/programmes" element={<Navigate to="/" replace/>}/><Route path="/parcours" element={isKineoFrance?<CurriculumPage/>:curriculumHome}/><Route path="/cours/:topicId" element={<CurriculumTopicPage/>}/><Route path="/lesson/:lessonId" element={isKineoFrance?<LessonPage/>:curriculumHome}/><Route path="/bibliotheque" element={isKineoFrance?<LibraryPage/>:curriculumHome}/><Route path="/revision" element={isKineoFrance?<RevisionContentGate><RevisionPage/></RevisionContentGate>:curriculumHome}/><Route path="/revision-matiere" element={isKineoFrance?<SubjectRevisionPage/>:curriculumHome}/><Route path="/session/:sessionId" element={isKineoFrance?<SessionReviewPage/>:curriculumHome}/><Route path="/defi-cursus/:challengeId" element={<CurriculumChallengePage/>}/><Route path="/anatomie" element={isKineoFrance?<RevisionModeGate mode="visual"><VisualRevisionPage/></RevisionModeGate>:curriculumHome}/><Route path="/mes-erreurs" element={isKineoFrance?<RevisionModeGate mode="weak"><WeakRevisionPage/></RevisionModeGate>:curriculumHome}/><Route path="/examen" element={isKineoFrance?<RevisionModeGate mode="exam"><MockExamPage/></RevisionModeGate>:curriculumHome}/><Route path="/stats" element={isKineoFrance?<StatisticsPage/>:<GamificationPage/>}/><Route path="/rewards" element={<GamificationPage/>}/><Route path="/classement" element={<LeaderboardPage/>}/><Route path="/profil" element={<ProfilePage/>}/><Route path="/amis" element={<FriendsPage/>}/><Route path="/notifications" element={<NotificationsPage/>}/><Route path="/admin" element={<AdminGate><AdminPage/></AdminGate>}/><Route path="/admin/visuels" element={<AdminGate><VisualAdminPage/></AdminGate>}/><Route path="*" element={<NotFoundPage/>}/></Routes></main><FeedbackButton/><nav className="bottom-nav" aria-label={isSpain?'Navegación principal':'Navigation principale'}>{navItems.map(item=><NavLink key={item.to} to={item.to} end={item.end}><span className="nav-icon" aria-hidden="true">{item.icon}</span><span>{item.label}</span></NavLink>)}</nav></div></AuthGate>}
