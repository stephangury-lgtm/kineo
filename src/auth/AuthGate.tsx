import { useEffect, useState, type ReactNode } from 'react'
import type { Session } from '@supabase/supabase-js'
import { supabase } from '../lib/supabase'
import LoginPage from '../pages/LoginPage'

type Props = { children: ReactNode }

export default function AuthGate({ children }: Props) {
  const [session, setSession] = useState<Session | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    supabase.auth.getSession().then(({ data }) => {
      setSession(data.session)
      setLoading(false)
    })

    const { data } = supabase.auth.onAuthStateChange((_event, nextSession) => {
      setSession(nextSession)
      setLoading(false)
    })

    return () => data.subscription.unsubscribe()
  }, [])

  if (loading) {
    return <main className="auth-shell"><section className="card centered"><p>Ouverture de Kineo…</p></section></main>
  }

  if (!session) return <LoginPage />
  return <>{children}</>
}
