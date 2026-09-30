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
      <section className="auth-visual">
        <div className="auth-logo">K</div>
        <p className="eyebrow light">Kineo · Révision kiné</p>
        <h1>Progresse un peu chaque jour.</h1>
        <p>Des sessions courtes, un parcours K1–K4 et une révision qui s’adapte à tes erreurs.</p>
        <div className="auth-pills"><span>🔥 Séries</span><span>🧠 SRS</span><span>🏆 Badges</span></div>
      </section>

      <section className="card auth-card">
        <div>
          <p className="eyebrow">{mode === 'login' ? 'Connexion' : 'Inscription'}</p>
          <h2>{mode === 'login' ? 'Content de te revoir 👋' : 'Créer mon compte'}</h2>
          <p>{mode === 'login' ? 'Reprends ta progression là où tu l’as laissée.' : 'Quelques secondes suffisent pour commencer.'}</p>
        </div>

        <form className="auth-form" onSubmit={submit}>
          <label>E-mail<input type="email" value={email} onChange={(e) => setEmail(e.target.value)} required autoComplete="email" placeholder="prenom@email.fr" /></label>
          <label>Mot de passe<input type="password" value={password} onChange={(e) => setPassword(e.target.value)} minLength={6} required autoComplete={mode === 'login' ? 'current-password' : 'new-password'} placeholder="••••••••" /></label>
          <button className="primary-button wide" disabled={busy} type="submit">{busy ? 'Patiente…' : mode === 'login' ? 'Se connecter' : 'Créer mon compte'}</button>
        </form>

        {message && <p className="feedback">{message}</p>}
        <button className="link-button" type="button" onClick={() => setMode(mode === 'login' ? 'signup' : 'login')}>
          {mode === 'login' ? 'Je n’ai pas encore de compte' : 'J’ai déjà un compte'}
        </button>
      </section>
    </main>
  )
}
