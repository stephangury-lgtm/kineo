import { useState, type FormEvent } from 'react'
import { supabase } from '../lib/supabase'

type Props = { onDone: () => void }

export default function ResetPasswordPage({ onDone }: Props) {
  const [password, setPassword] = useState('')
  const [confirmPassword, setConfirmPassword] = useState('')
  const [showPassword, setShowPassword] = useState(false)
  const [message, setMessage] = useState<string | null>(null)
  const [messageType,setMessageType]=useState<'error'|'success'|null>(null)
  const [busy, setBusy] = useState(false)

  async function submit(event: FormEvent) {
    event.preventDefault()
    setMessage(null)
    setMessageType(null)
    if (password.length < 8) {
      setMessageType('error')
      setMessage('Le mot de passe doit contenir au moins 8 caractères.')
      return
    }
    if (password !== confirmPassword) {
      setMessageType('error')
      setMessage('Les deux mots de passe ne correspondent pas.')
      return
    }

    setBusy(true)
    try {
      const { error } = await supabase.auth.updateUser({ password })
      if (error) throw error
      setMessageType('success')
      setMessage('Mot de passe modifié avec succès.')
      window.setTimeout(onDone, 600)
    } catch (err) {
      setMessageType('error')
      const text=err instanceof Error?err.message.toLowerCase():''
      setMessage(text.includes('password should be at least')?'Le mot de passe doit contenir au moins 8 caractères.':'Impossible de modifier le mot de passe. Réessaie dans un instant.')
    } finally {
      setBusy(false)
    }
  }

  return (
    <main className="auth-shell">
      <section className="card auth-card">
        <div>
          <p className="eyebrow">Sécurité</p>
          <h1>Choisis un nouveau mot de passe</h1>
          <p>Entre ton nouveau mot de passe pour récupérer l’accès à Kineo.</p>
        </div>

        <form className="auth-form" onSubmit={submit} noValidate>
          <label>
            Nouveau mot de passe
            <div className="password-field">
              <input type={showPassword?'text':'password'} value={password} onChange={(e) => setPassword(e.target.value)} minLength={8} required autoComplete="new-password" />
              <button className="password-toggle" type="button" onClick={()=>setShowPassword(value=>!value)} aria-label={showPassword?'Masquer le mot de passe':'Afficher le mot de passe'} aria-pressed={showPassword}>{showPassword?'🙈':'👁️'}</button>
            </div>
          </label>
          <label>
            Confirmer le mot de passe
            <input type={showPassword?'text':'password'} value={confirmPassword} onChange={(e) => setConfirmPassword(e.target.value)} minLength={8} required autoComplete="new-password" />
          </label>
          <button className="primary-button wide" disabled={busy} type="submit">{busy ? 'Enregistrement…' : 'Enregistrer le nouveau mot de passe'}</button>
        </form>

        {message && <p className={`auth-feedback ${messageType??''}`} role={messageType==='error'?'alert':'status'}>{message}</p>}
      </section>
    </main>
  )
}
