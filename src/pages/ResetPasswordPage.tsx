import { useState, type FormEvent } from 'react'
import { supabase } from '../lib/supabase'

type Props = { onDone: () => void }

export default function ResetPasswordPage({ onDone }: Props) {
  const [password, setPassword] = useState('')
  const [confirmPassword, setConfirmPassword] = useState('')
  const [message, setMessage] = useState<string | null>(null)
  const [busy, setBusy] = useState(false)

  async function submit(event: FormEvent) {
    event.preventDefault()
    if (password.length < 6) {
      setMessage('Le mot de passe doit contenir au moins 6 caractères.')
      return
    }
    if (password !== confirmPassword) {
      setMessage('Les deux mots de passe ne correspondent pas.')
      return
    }

    setBusy(true)
    setMessage(null)
    try {
      const { error } = await supabase.auth.updateUser({ password })
      if (error) throw error
      setMessage('Mot de passe modifié avec succès.')
      setTimeout(onDone, 600)
    } catch (err) {
      setMessage(err instanceof Error ? err.message : 'Impossible de modifier le mot de passe.')
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

        <form className="auth-form" onSubmit={submit}>
          <label>Nouveau mot de passe<input type="password" value={password} onChange={(e) => setPassword(e.target.value)} minLength={6} required autoComplete="new-password" /></label>
          <label>Confirmer le mot de passe<input type="password" value={confirmPassword} onChange={(e) => setConfirmPassword(e.target.value)} minLength={6} required autoComplete="new-password" /></label>
          <button className="primary-button wide" disabled={busy} type="submit">{busy ? 'Enregistrement…' : 'Enregistrer le nouveau mot de passe'}</button>
        </form>

        {message && <p className="feedback">{message}</p>}
      </section>
    </main>
  )
}
