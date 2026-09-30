import { useState, type FormEvent } from 'react'
import { supabase } from '../lib/supabase'

export default function LoginPage() {
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [mode, setMode] = useState<'login' | 'signup'>('login')
  const [message, setMessage] = useState<string | null>(null)
  const [busy, setBusy] = useState(false)

  async function submit(event: FormEvent) {
    event.preventDefault()
    setBusy(true)
    setMessage(null)

    try {
      if (mode === 'login') {
        const { error } = await supabase.auth.signInWithPassword({ email, password })
        if (error) throw error
      } else {
        const { data, error } = await supabase.auth.signUp({ email, password })
        if (error) throw error
        if (!data.session) setMessage('Compte créé. Vérifie ton e-mail pour confirmer ton inscription.')
      }
    } catch (err) {
      setMessage(err instanceof Error ? err.message : 'Connexion impossible.')
    } finally {
      setBusy(false)
    }
  }

  return (
    <main className="auth-shell">
      <section className="card auth-card">
        <div>
          <p className="eyebrow">Kineo</p>
          <h1>{mode === 'login' ? 'Bon retour 👋' : 'Créer mon compte'}</h1>
          <p>Révisions kiné courtes, personnalisées et basées sur ta progression.</p>
        </div>

        <form className="auth-form" onSubmit={submit}>
          <label>
            E-mail
            <input type="email" value={email} onChange={(e) => setEmail(e.target.value)} required autoComplete="email" />
          </label>
          <label>
            Mot de passe
            <input type="password" value={password} onChange={(e) => setPassword(e.target.value)} minLength={6} required autoComplete={mode === 'login' ? 'current-password' : 'new-password'} />
          </label>
          <button className="primary-button" disabled={busy} type="submit">
            {busy ? 'Patiente…' : mode === 'login' ? 'Se connecter' : 'Créer mon compte'}
          </button>
        </form>

        {message && <p className="feedback">{message}</p>}

        <button className="link-button" type="button" onClick={() => setMode(mode === 'login' ? 'signup' : 'login')}>
          {mode === 'login' ? 'Je n’ai pas encore de compte' : 'J’ai déjà un compte'}
        </button>
      </section>
    </main>
  )
}
