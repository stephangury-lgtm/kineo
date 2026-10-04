import { useEffect, useState, type ReactNode } from 'react'
import type { Session } from '@supabase/supabase-js'
import { supabase } from '../lib/supabase'
import { PROGRAM_STORAGE_KEY, selectProgram } from '../curriculum/programs'
import LoginPage from '../pages/LoginPage'
import ProfileSetupPage from '../pages/ProfileSetupPage'
import ResetPasswordPage from '../pages/ResetPasswordPage'
import { getCurrentProfile, type StudentProfile } from '../services/profileApi'
import { getPrimaryProgram, type PrimaryProgram } from '../services/programApi'

type Props = { children: ReactNode }

export default function AuthGate({ children }: Props) {
  const [session, setSession] = useState<Session | null>(null)
  const [profile, setProfile] = useState<StudentProfile | null>(null)
  const [primaryProgram,setPrimaryProgram]=useState<PrimaryProgram|null>(null)
  const [loading, setLoading] = useState(true)
  const [profileError, setProfileError] = useState<string | null>(null)
  const [passwordRecovery, setPasswordRecovery] = useState(false)

  async function loadProfile(nextSession: Session | null) {
    setSession(nextSession)
    setProfileError(null)
    if (!nextSession) {
      setProfile(null)
      setPrimaryProgram(null)
      setLoading(false)
      return
    }

    try {
      const [nextProfile,nextProgram]=await Promise.all([getCurrentProfile(),getPrimaryProgram()])
      setProfile(nextProfile)
      setPrimaryProgram(nextProgram)
      if(nextProgram){
        const stored=localStorage.getItem(PROGRAM_STORAGE_KEY)
        selectProgram(nextProgram.program_id)
        if(nextProgram.level_code)localStorage.setItem(`healthapp_level_${nextProgram.program_id}`,nextProgram.level_code)
        if(stored&&stored!==nextProgram.program_id){window.location.reload();return}
      }
    } catch (err) {
      setProfileError(err instanceof Error ? err.message : 'Profil indisponible')
    } finally {
      setLoading(false)
    }
  }

  async function signOut() {
    setLoading(true)
    await supabase.auth.signOut()
    setProfile(null)
    setPrimaryProgram(null)
    setSession(null)
    setLoading(false)
  }

  useEffect(() => {
    supabase.auth.getSession().then(({ data }) => loadProfile(data.session))

    const { data } = supabase.auth.onAuthStateChange((event, nextSession) => {
      if (event === 'PASSWORD_RECOVERY') {
        setPasswordRecovery(true)
        setSession(nextSession)
        setLoading(false)
        return
      }
      setLoading(true)
      void loadProfile(nextSession)
    })

    return () => data.subscription.unsubscribe()
  }, [])

  if (loading) {
    return <main className="auth-shell"><section className="card centered"><p>Ouverture de ton espace…</p></section></main>
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

  if (!primaryProgram || !primaryProgram.academic_level_id) {
    return <ProfileSetupPage current={profile} onSaved={setProfile} />
  }

  return <>{children}</>
}
