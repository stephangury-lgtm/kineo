import { useState, type FormEvent } from 'react'
import { supabase } from '../lib/supabase'
import './LoginPage.css'

function translateAuthError(error: unknown) {
  const message = error instanceof Error ? error.message.toLowerCase() : ''
  if (message.includes('invalid login credentials')) return 'E-mail ou mot de passe incorrect.'
  if (message.includes('email not confirmed')) return 'Ton adresse e-mail n’est pas encore confirmée.'
  if (message.includes('user already registered')) return 'Un compte existe déjà avec cette adresse e-mail.'
  if (message.includes('password should be at least')) return 'Le mot de passe doit contenir au moins 6 caractères.'
  if (message.includes('rate limit')) return 'Trop de tentatives. Réessaie dans quelques instants.'
  return 'Une erreur est survenue. Réessaie dans un instant.'
}

export default function LoginPage() {
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [showPassword, setShowPassword] = useState(false)
  const [mode, setMode] = useState<'login' | 'signup'>('login')
  const [message, setMessage] = useState<string | null>(null)
  const [messageType, setMessageType] = useState<'error' | 'success' | null>(null)
  const [busy, setBusy] = useState(false)

  function clearFeedback() {
    setMessage(null)
    setMessageType(null)
  }

  async function submit(event: FormEvent) {
    event.preventDefault()
    setBusy(true)
    clearFeedback()
    try {
      if (mode === 'login') {
        const { error } = await supabase.auth.signInWithPassword({ email, password })
        if (error) throw error
      } else {
        const { data, error } = await supabase.auth.signUp({ email, password })
        if (error) throw error
        if (!data.session) {
          setMessageType('success')
          setMessage('Compte créé. Vérifie ton e-mail pour confirmer ton inscription.')
        }
      }
    } catch (err) {
      setMessageType('error')
      setMessage(translateAuthError(err))
    } finally {
      setBusy(false)
    }
  }

  async function requestPasswordReset() {
    if (!email.trim()) {
      setMessageType('error')
      setMessage('Saisis d’abord ton adresse e-mail.')
      return
    }
    setBusy(true)
    clearFeedback()
    try {
      const { error } = await supabase.auth.resetPasswordForEmail(email.trim(), {
        redirectTo: window.location.origin,
      })
      if (error) throw error
      setMessageType('success')
      setMessage('E-mail de récupération envoyé. Vérifie ta boîte de réception et tes courriers indésirables.')
    } catch (err) {
      setMessageType('error')
      setMessage(translateAuthError(err))
    } finally {
      setBusy(false)
    }
  }

  function switchMode() {
    setMode(current => current === 'login' ? 'signup' : 'login')
    setShowPassword(false)
    clearFeedback()
  }

  const hasError = messageType === 'error'

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
          <label>
            E-mail
            <input
              type="email"
              value={email}
              onChange={(e) => { setEmail(e.target.value); clearFeedback() }}
              required
              autoComplete="email"
              placeholder="prenom@email.fr"
              aria-invalid={hasError}
            />
          </label>
          <label>
            Mot de passe
            <div className="password-field">
              <input
                type={showPassword ? 'text' : 'password'}
                value={password}
                onChange={(e) => { setPassword(e.target.value); clearFeedback() }}
                minLength={6}
                required
                autoComplete={mode === 'login' ? 'current-password' : 'new-password'}
                placeholder="••••••••"
                aria-invalid={hasError}
              />
              <button
                className="password-toggle"
                type="button"
                onClick={() => setShowPassword(value => !value)}
                aria-label={showPassword ? 'Masquer le mot de passe' : 'Afficher le mot de passe'}
                aria-pressed={showPassword}
              >
                {showPassword ? '🙈' : '👁️'}
              </button>
            </div>
          </label>
          <button className="primary-button wide" disabled={busy} type="submit">{busy ? 'Patiente…' : mode === 'login' ? 'Se connecter' : 'Créer mon compte'}</button>
        </form>

        {mode === 'login' && (
          <button className="link-button auth-secondary-action" type="button" onClick={requestPasswordReset} disabled={busy}>
            Mot de passe oublié ?
          </button>
        )}

        {message && <p className={`auth-feedback ${messageType ?? ''}`} role={messageType === 'error' ? 'alert' : 'status'}>{message}</p>}

        <button className="link-button auth-account-action" type="button" onClick={switchMode}>
          {mode === 'login' ? 'Je n’ai pas encore de compte' : 'J’ai déjà un compte'}
        </button>
      </section>
    </main>
  )
}
