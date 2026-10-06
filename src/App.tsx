import { Suspense, lazy } from 'react'
import { NavLink, Navigate, Route, Routes } from 'react-router-dom'
import AdminGate from './auth/AdminGate'
import AuthGate from './auth/AuthGate'
import RevisionContentGate from './auth/RevisionContentGate'
import RevisionModeGate from './auth/RevisionModeGate'
import VisualReviewGate from './auth/VisualReviewGate'
import ExamTimerBar from './components/ExamTimerBar'
import FeedbackButton from './components/FeedbackButton'
import HeaderProfileButton from './components/HeaderProfileButton'
import HeaderXpBadge from './components/HeaderXpBadge'
import NotificationBell from './components/NotificationBell'
import OfflineStatus from './components/OfflineStatus'
import { getCurrentProgram } from './curriculum/programs'
import DashboardPage from './pages/DashboardPage'
import NotFoundPage from './pages/NotFoundPage'
import './pages/RevisionPage.css'
import './curriculum.css'
import './feedback-fixes.css'

const AdminPage=lazy(()=>import('./pages/AdminPage'))
const CurriculumChallengePage=lazy(()=>import('./pages/CurriculumChallengePage'))
const CurriculumPage=lazy(()=>import('./pages/CurriculumPage'))
const CurriculumTopicPage=lazy(()=>import('./pages/CurriculumTopicPage'))
const FoundationsPage=lazy(()=>import('./pages/FoundationsPage'))
const FriendsPage=lazy(()=>import('./pages/FriendsPage'))
const GamificationPage=lazy(()=>import('./pages/GamificationPage'))
const LeaderboardPage=lazy(()=>import('./pages/LeaderboardPage'))
const LessonPage=lazy(()=>import('./pages/LessonPage'))
const LibraryPage=lazy(()=>import('./pages/LibraryPage'))
const MockExamPage=lazy(()=>import('./pages/MockExamPage'))
const NotificationsPage=lazy(()=>import('./pages/NotificationsPage'))
const ProfilePage=lazy(()=>import('./pages/ProfilePage'))
const ProgramHomePage=lazy(()=>import('./pages/ProgramHomePage'))
const ProgramLandingPage=lazy(()=>import('./pages/ProgramLandingPage'))
const RevisionPage=lazy(()=>import('./pages/RevisionPage'))
const SessionReviewPage=lazy(()=>import('./pages/SessionReviewPage'))
const StatisticsPage=lazy(()=>import('./pages/StatisticsPage'))
const SubjectRevisionPage=lazy(()=>import('./pages/SubjectRevisionPage'))
const VisualAdminPage=lazy(()=>import('./pages/VisualAdminPage'))
const VisualReviewerPage=lazy(()=>import('./pages/VisualReviewerPage'))
const VisualRevisionPage=lazy(()=>import('./pages/VisualRevisionPage'))
const WeakRevisionPage=lazy(()=>import('./pages/WeakRevisionPage'))

const routeFallback=<section className="card skeleton-card"><p>Chargement…</p></section>

export default function App(){
 const program=getCurrentProgram(),isKineoFrance=program.id==='kineo-fr',isSpain=program.id==='kineo-es'
 const navItems=isKineoFrance
  ?[{to:'/',label:'Accueil',icon:'⌂',end:true},{to:'/parcours',label:'Parcours',icon:'▦'},{to:'/revision',label:'Réviser',icon:'✦'},{to:'/stats',label:'Stats',icon:'↗'},{to:'/rewards',label:'Badges',icon:'★'}]
  :isSpain
   ?[{to:'/',label:'Inicio',icon:'⌂',end:true},{to:'/parcours',label:'Temario',icon:'▦'},{to:'/amis',label:'Amigos',icon:'⚔'},{to:'/rewards',label:'Logros',icon:'★'},{to:'/profil',label:'Perfil',icon:'●'}]
   :[{to:'/',label:'Accueil',icon:'⌂',end:true},{to:'/parcours',label:'Cursus',icon:'▦'},{to:'/amis',label:'Amis',icon:'⚔'},{to:'/rewards',label:'Badges',icon:'★'},{to:'/profil',label:'Profil',icon:'●'}]
 const curriculumHome=<ProgramLandingPage/>
 const programHome=<ProgramHomePage/>
 return <AuthGate><div className="app-shell"><OfflineStatus/><header className="topbar"><div className="brand-lockup"><span className="brand-mark">{program.accent}</span><div><strong className="brand">{program.shortName}</strong><span className="tagline">{isKineoFrance?'Réviser. Progresser. Retenir.':program.subtitle}</span><span className="brand-platform">{isSpain?'Plataforma salud · tu grado':'Plateforme santé'}</span></div></div><div className="topbar-actions">{isKineoFrance&&<HeaderXpBadge/>}{!isKineoFrance&&<FeedbackButton inline/>}<NotificationBell/><HeaderProfileButton/></div></header><ExamTimerBar/><main className="content"><Suspense fallback={routeFallback}><Routes><Route path="/" element={isKineoFrance?<DashboardPage/>:programHome}/><Route path="/programmes" element={<Navigate to="/" replace/>}/><Route path="/parcours" element={isKineoFrance?<CurriculumPage/>:curriculumHome}/><Route path="/fondamentaux" element={<FoundationsPage/>}/><Route path="/cours/:topicId" element={<CurriculumTopicPage/>}/><Route path="/lesson/:lessonId" element={isKineoFrance?<LessonPage/>:curriculumHome}/><Route path="/bibliotheque" element={isKineoFrance?<LibraryPage/>:curriculumHome}/><Route path="/revision" element={isKineoFrance?<RevisionContentGate><RevisionPage/></RevisionContentGate>:curriculumHome}/><Route path="/revision-matiere" element={isKineoFrance?<SubjectRevisionPage/>:curriculumHome}/><Route path="/session/:sessionId" element={isKineoFrance?<SessionReviewPage/>:curriculumHome}/><Route path="/defi-cursus/:challengeId" element={<CurriculumChallengePage/>}/><Route path="/anatomie" element={isKineoFrance?<RevisionModeGate mode="visual"><VisualRevisionPage/></RevisionModeGate>:curriculumHome}/><Route path="/mes-erreurs" element={isKineoFrance?<RevisionModeGate mode="weak"><WeakRevisionPage/></RevisionModeGate>:curriculumHome}/><Route path="/examen" element={isKineoFrance?<RevisionModeGate mode="exam"><MockExamPage/></RevisionModeGate>:curriculumHome}/><Route path="/stats" element={isKineoFrance?<StatisticsPage/>:<GamificationPage/>}/><Route path="/rewards" element={<GamificationPage/>}/><Route path="/classement" element={<LeaderboardPage/>}/><Route path="/profil" element={<ProfilePage/>}/><Route path="/amis" element={<FriendsPage/>}/><Route path="/notifications" element={<NotificationsPage/>}/><Route path="/admin" element={<AdminGate><AdminPage/></AdminGate>}/><Route path="/admin/visuels" element={<AdminGate><VisualAdminPage/></AdminGate>}/><Route path="/relecture-visuels" element={<VisualReviewGate><VisualReviewerPage/></VisualReviewGate>}/><Route path="*" element={<NotFoundPage/>}/></Routes></Suspense></main>{isKineoFrance&&<FeedbackButton/>}<nav className="bottom-nav" aria-label={isSpain?'Navegación principal':'Navigation principale'}>{navItems.map(item=><NavLink key={item.to} to={item.to} end={item.end}><span className="nav-icon" aria-hidden="true">{item.icon}</span><span>{item.label}</span></NavLink>)}</nav></div></AuthGate>}
