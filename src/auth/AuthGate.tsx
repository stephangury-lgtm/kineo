import { useEffect, useState, type ReactNode } from 'react'
import type { Session } from '@supabase/supabase-js'
import { supabase } from '../lib/supabase'
import LoginPage from '../pages/LoginPage'
import ProfileSetupPage from '../pages/ProfileSetupPage'
import { getCurrentProfile, type StudentProfile } from '../services/profileApi'

type Props = { children: ReactNode }

export default function AuthGate({ children }: Props) {
  const [session, setSession] = useState<Session | null>(null)
  const [profile, setProfile] = useState<StudentProfile | null>(null)
  const [loading, setLoading] = useState(true)
  const [profileError, setProfileError] = useState<string | null>(null)

  async function loadProfile(nextSession: Session | null) {
    setSession(nextSession)
    setProfileError(null)
    if (!nextSession) {
      setProfile(null)
      setLoading(false)
      return
    }

    try {
      setProfile(await getCurrentProfile())
    } catch (err) {
      setProfileError(err instanceof Error ? err.message : 'Profil indisponible')
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    supabase.auth.getSession().then(({ data }) => loadProfile(data.session))

    const { data } = supabase.auth.onAuthStateChange((_event, nextSession) => {
      setLoading(true)
      void loadProfile(nextSession)
    })

    return () => data.subscription.unsubscribe()
  }, [])

  if (loading) {
    return <main className="auth-shell"><section className="card centered"><p>Ouverture de Kineo…</p></section></main>
  }

  if (!session) return <LoginPage />

  if (profileError) {
    return <main className="auth-shell"><section className="card centered"><h1>Profil indisponible</h1><p>{profileError}</p><button className="primary-button" onClick={() => void loadProfile(session)}>Réessayer</button></section></main>
  }

  if (!profile) {
    return <main className="auth-shell"><section className="card centered"><h1>Profil introuvable</h1><p>Ton compte est connecté mais aucun profil Kineo n’est encore associé.</p></section></main>
  }

  if (!profile.study_year) {
    return <ProfileSetupPage current={profile} onSaved={setProfile} />
  }

  return <>{children}</>
}
