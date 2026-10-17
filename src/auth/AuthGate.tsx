import { useEffect, useRef, useState, type ReactNode } from 'react'
import type { Session } from '@supabase/supabase-js'
import { supabase } from '../lib/supabase'
import { PROGRAM_STORAGE_KEY, selectProgram, type ProgramId } from '../curriculum/programs'
import LoginPage from '../pages/LoginPage'
import {AuthenticatedStudent} from './AuthenticatedStudent'
import {clearDailySnapshots} from '../learning/daily-session-storage'
import ProfileSetupPage from '../pages/ProfileSetupPage'
import ResetPasswordPage from '../pages/ResetPasswordPage'
import { getCurrentProfile, markAppOpen, touchUserActivity, type StudentProfile } from '../services/profileApi'
import { getAccessiblePrograms, type PrimaryProgram } from '../services/programApi'

type Props = { children: ReactNode }

export default function AuthGate({ children }: Props) {
  const [session, setSession] = useState<Session | null>(null)
  const [profile, setProfile] = useState<StudentProfile | null>(null)
  const [primaryProgram,setPrimaryProgram]=useState<PrimaryProgram|null>(null)
  const [loading, setLoading] = useState(true)
  const [slowLoading, setSlowLoading] = useState(false)
  const loadVersion = useRef(0)
  const slowTimer = useRef<number | null>(null)
  const [profileError, setProfileError] = useState<string | null>(null)
  const [passwordRecovery, setPasswordRecovery] = useState(false)

  async function loadProfile(nextSession: Session | null) {
    const version = ++loadVersion.current
    if (slowTimer.current !== null) window.clearTimeout(slowTimer.current)
    setLoading(true)
    setSlowLoading(false)
    setSession(nextSession)
    setProfileError(null)
    setProfile(null)
    setPrimaryProgram(null)
    if (!nextSession) {
      setProfile(null)
      setPrimaryProgram(null)
      setLoading(false)
      return
    }

    slowTimer.current = window.setTimeout(() => {
      if (version === loadVersion.current) setSlowLoading(true)
    }, 12000)

    try {
      const userId=nextSession.user.id
      const [nextProfile,accessiblePrograms]=await Promise.all([getCurrentProfile(userId),getAccessiblePrograms(userId)])
      if (version !== loadVersion.current) return
      void markAppOpen().catch(()=>undefined)
      const primary=accessiblePrograms.find(program=>program.is_primary)??null
      const nextProgram=primary
        ? {program_id:primary.program_id,academic_level_id:primary.academic_level_id,level_code:primary.level_code,curriculum_version:primary.curriculum_version}
        : null
      setProfile(nextProfile)
      setPrimaryProgram(nextProgram)
      if(nextProgram){
        const stored=localStorage.getItem(PROGRAM_STORAGE_KEY) as ProgramId|null
        const storedIsAccessible=Boolean(stored&&accessiblePrograms.some(program=>program.program_id===stored))
        const selectedProgram=storedIsAccessible&&stored ? stored : nextProgram.program_id
        const selectedAccess=accessiblePrograms.find(program=>program.program_id===selectedProgram)
        selectProgram(selectedProgram)
        if(selectedAccess?.level_code)localStorage.setItem(`healthapp_level_${selectedProgram}`,selectedAccess.level_code)
        if(selectedAccess?.curriculum_version)localStorage.setItem(`healthapp_curriculum_${selectedProgram}`,selectedAccess.curriculum_version)
        if(stored!==selectedProgram){window.location.reload();return}
      }
    } catch (err) {
      if (version === loadVersion.current) setProfileError(err instanceof Error ? err.message : 'Profil indisponible')
    } finally {
      if (version === loadVersion.current) {
        if (slowTimer.current !== null) window.clearTimeout(slowTimer.current)
        slowTimer.current = null
        setLoading(false)
        setSlowLoading(false)
      }
    }
  }

  async function signOut() {
    try {
      const { error } = await supabase.auth.signOut()
      if (error) throw error
      setPasswordRecovery(false)
      await loadProfile(null)
    } catch {
      ++loadVersion.current
      if (slowTimer.current !== null) window.clearTimeout(slowTimer.current)
      slowTimer.current = null
      setSlowLoading(false)
      setLoading(false)
      setProfileError('Impossible de se déconnecter. Vérifie ta connexion puis réessaie.')
    }
  }

  useEffect(() => {
    const initialVersion = loadVersion.current
    supabase.auth.getSession().then(({ data, error }) => {
      if (initialVersion !== loadVersion.current) return
      if (error) throw error
      return loadProfile(data.session)
    }).catch(() => { if (initialVersion === loadVersion.current) setLoading(false) })

    const { data } = supabase.auth.onAuthStateChange((event, nextSession) => {
      if(event==='SIGNED_OUT')clearDailySnapshots()
      if (event === 'INITIAL_SESSION') return
      if (event === 'PASSWORD_RECOVERY') {
        ++loadVersion.current
        if (slowTimer.current !== null) window.clearTimeout(slowTimer.current)
        setPasswordRecovery(true)
        setSession(nextSession)
        setLoading(false)
        return
      }
      if (!nextSession) setPasswordRecovery(false)
      void loadProfile(nextSession)
    })

    return () => {
      ++loadVersion.current
      if (slowTimer.current !== null) window.clearTimeout(slowTimer.current)
      data.subscription.unsubscribe()
    }
  }, [])

  useEffect(()=>{
    if(!session)return

    let lastActivityAt=0
    let lastOpenAt=Date.now()

    const recordActivity=()=>{
      const now=Date.now()
      if(now-lastActivityAt<60_000)return
      lastActivityAt=now
      void touchUserActivity().catch(()=>undefined)
    }

    const recordOpen=()=>{
      const now=Date.now()
      if(now-lastOpenAt<60_000)return
      lastOpenAt=now
      void markAppOpen().catch(()=>undefined)
    }

    const onVisibility=()=>{
      if(document.visibilityState==='visible'){recordOpen();recordActivity()}
    }

    recordActivity()

    window.addEventListener('pointerdown',recordActivity,{passive:true})
    window.addEventListener('keydown',recordActivity)
    window.addEventListener('touchstart',recordActivity,{passive:true})
    document.addEventListener('visibilitychange',onVisibility)

    return()=>{
      window.removeEventListener('pointerdown',recordActivity)
      window.removeEventListener('keydown',recordActivity)
      window.removeEventListener('touchstart',recordActivity)
      document.removeEventListener('visibilitychange',onVisibility)
    }
  },[session?.user.id])

  if (loading) {
    return <main className="auth-shell"><section className="card centered"><p role="status">{slowLoading ? 'Le chargement prend plus de temps que prévu. Vérifie ta connexion Internet.' : 'Ouverture de ton espace…'}</p>{slowLoading && session && <div className="completion-actions"><button className="primary-button" onClick={() => void loadProfile(session)}>Réessayer</button><button className="secondary-button" onClick={() => void signOut()}>Se déconnecter</button></div>}</section></main>
  }

  if (passwordRecovery && session) {
    return <ResetPasswordPage onDone={() => setPasswordRecovery(false)} />
  }

  if (!session) return <LoginPage />

  if (profileError) {
    return <main className="auth-shell"><section className="card centered"><h1>Profil indisponible</h1><p>Impossible de charger ton profil pour le moment.</p><div className="completion-actions"><button className="primary-button" onClick={() => void loadProfile(session)}>Réessayer</button><button className="secondary-button" onClick={() => void signOut()}>Se déconnecter</button></div></section></main>
  }

  if (!profile) {
    return <main className="auth-shell"><section className="card centered"><h1>Profil introuvable</h1><p>Ton compte est connecté mais le profil associé n’a pas pu être chargé.</p><div className="completion-actions"><button className="primary-button" onClick={() => void loadProfile(session)}>Réessayer</button><button className="secondary-button" onClick={() => void signOut()}>Se déconnecter</button></div></section></main>
  }

  if (!profile.study_year || !primaryProgram || !primaryProgram.academic_level_id) {
    return <ProfileSetupPage current={profile} existingProgram={primaryProgram} onSaved={setProfile} />
  }

  return <AuthenticatedStudent.Provider value={session.user.id}>{children}</AuthenticatedStudent.Provider>
}
