import { useState, type FormEvent } from 'react'
import { supabase } from '../lib/supabase'
import './LoginPage.css'

function translateAuthError(error: unknown) {
  const message = error instanceof Error ? error.message.toLowerCase() : ''
  if (message.includes('invalid login credentials')) return 'E-mail ou mot de passe incorrect.'
  if (message.includes('email not confirmed')) return 'Ton adresse e-mail n’est pas encore confirmée.'
  if (message.includes('user already registered')) return 'Un compte existe déjà avec cette adresse e-mail.'
  if (message.includes('password should be at least')) return 'Le mot de passe doit contenir au moins 8 caractères.'
  if (message.includes('rate limit')) return 'Trop de tentatives. Réessaie dans quelques instants.'
  return 'Une erreur est survenue. Réessaie dans un instant.'
}

type AuthMode='login'|'signup'|'reset'

export default function LoginPage() {
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [showPassword, setShowPassword] = useState(false)
  const [mode, setMode] = useState<AuthMode>('login')
  const [message, setMessage] = useState<string | null>(null)
  const [messageType, setMessageType] = useState<'error' | 'success' | null>(null)
  const [busy, setBusy] = useState(false)

  function clearFeedback() {
    setMessage(null)
    setMessageType(null)
  }

  function validateCredentials(){
    const normalizedEmail=email.trim()
    if(!normalizedEmail){setMessageType('error');setMessage('Saisis ton adresse e-mail.');return false}
    if(!/^\S+@\S+\.\S+$/.test(normalizedEmail)){setMessageType('error');setMessage('Saisis une adresse e-mail valide.');return false}
    if(mode!=='reset'&&!password){setMessageType('error');setMessage('Saisis ton mot de passe.');return false}
    if(mode==='signup'&&password.length<8){setMessageType('error');setMessage('Le mot de passe doit contenir au moins 8 caractères.');return false}
    return true
  }

  async function submit(event: FormEvent) {
    event.preventDefault()
    clearFeedback()
    if(!validateCredentials())return
    setBusy(true)
    try {
      if (mode === 'reset') {
        const { error } = await supabase.auth.resetPasswordForEmail(email.trim(), { redirectTo: window.location.origin })
        if (error) throw error
        setMessageType('success')
        setMessage('Lien de réinitialisation envoyé. Ouvre l’e-mail reçu puis choisis ton nouveau mot de passe.')
        return
      }
      if (mode === 'login') {
        const { error } = await supabase.auth.signInWithPassword({ email:email.trim(), password })
        if (error) throw error
      } else {
        const { data, error } = await supabase.auth.signUp({ email:email.trim(), password })
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

  function switchMode(next:AuthMode) {
    setMode(next)
    setPassword('')
    setShowPassword(false)
    clearFeedback()
  }

  const hasError = messageType === 'error'
  const isReset=mode==='reset'
  const title=mode==='login'?'Content de te revoir 👋':mode==='signup'?'Créer mon compte':'Réinitialiser mon mot de passe'
  const intro=mode==='login'?'Reprends ta progression là où tu l’as laissée.':mode==='signup'?'Quelques secondes suffisent pour commencer.':'Saisis ton e-mail. Nous t’enverrons un lien sécurisé pour choisir un nouveau mot de passe.'

  return (
    <main className="auth-shell">
      <section className="auth-visual">
        <img className="auth-brand-logo" src="/kineo-brand-logo.svg" alt="Kineo" />
        <p className="eyebrow light">Kineo · Plateforme santé</p>
        <h1>Progresse un peu chaque jour.</h1>
        <p>Des révisions courtes et gamifiées pour les étudiants en kinésithérapie et en soins infirmiers, en France et en Espagne.</p>
        <div className="auth-pills"><span>🔥 Séries</span><span>🧠 SRS</span><span>🏆 Badges</span></div>
      </section>

      <section className="card auth-card">
        <div>
          <p className="eyebrow">{mode === 'login' ? 'Connexion' : mode==='signup'?'Inscription':'Récupération'}</p>
          <h2>{title}</h2>
          <p>{intro}</p>
        </div>

        <form className="auth-form" onSubmit={submit} noValidate>
          <label>
            E-mail
            <input
              type="email"
              value={email}
              onChange={(e) => { setEmail(e.target.value); clearFeedback() }}
              autoComplete="email"
              inputMode="email"
              placeholder="prenom@email.fr"
              aria-invalid={hasError}
            />
          </label>
          {!isReset&&<label>
            Mot de passe
            <div className="password-field">
              <input
                type={showPassword ? 'text' : 'password'}
                value={password}
                onChange={(e) => { setPassword(e.target.value); clearFeedback() }}
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
          </label>}
          <button className="primary-button wide" disabled={busy} type="submit">{busy ? 'Patiente…' : mode === 'login' ? 'Se connecter' : mode==='signup' ? 'Créer mon compte':'Envoyer le lien de réinitialisation'}</button>
        </form>

        {mode === 'login' && (
          <button className="link-button auth-secondary-action" type="button" onClick={()=>switchMode('reset')} disabled={busy}>
            Mot de passe oublié ?
          </button>
        )}

        {message && <p className={`auth-feedback ${messageType ?? ''}`} role={messageType === 'error' ? 'alert' : 'status'}>{message}</p>}

        {mode==='login'?<button className="link-button auth-account-action" type="button" onClick={()=>switchMode('signup')}>Je n’ai pas encore de compte</button>:<button className="link-button auth-account-action" type="button" onClick={()=>switchMode('login')}>{mode==='reset'?'← Retour à la connexion':'J’ai déjà un compte'}</button>}
      </section>
    </main>
  )
}
