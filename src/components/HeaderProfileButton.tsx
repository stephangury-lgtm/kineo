import { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import { getCurrentProfile } from '../services/profileApi'

export default function HeaderProfileButton() {
  const [avatarUrl, setAvatarUrl] = useState<string | null>(null)
  const [initial, setInitial] = useState('')

  useEffect(() => {
    void getCurrentProfile().then((profile) => {
      setAvatarUrl(profile?.avatar_url ?? null)
      setInitial((profile?.first_name || profile?.username || '').slice(0, 1).toUpperCase())
    }).catch(() => undefined)

    const refresh = () => {
      void getCurrentProfile().then((profile) => {
        setAvatarUrl(profile?.avatar_url ?? null)
        setInitial((profile?.first_name || profile?.username || '').slice(0, 1).toUpperCase())
      }).catch(() => undefined)
    }
    window.addEventListener('kineo-profile-updated', refresh)
    return () => window.removeEventListener('kineo-profile-updated', refresh)
  }, [])

  return (
    <Link className="header-avatar-button" aria-label="Ouvrir mon compte" to="/profil">
      {avatarUrl ? <img src={avatarUrl} alt="Ma photo de profil" /> : <span aria-hidden="true">{initial || '👤'}</span>}
      <i className="avatar-status-dot" aria-hidden="true" />
    </Link>
  )
}
