import { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import { getCurrentProfile } from '../services/profileApi'
import { getCurrentProgram } from '../curriculum/programs'

export default function HeaderProfileButton() {
  const isSpain=getCurrentProgram().id==='kineo-es'
  const [avatarUrl, setAvatarUrl] = useState<string | null>(null)
  const [initial, setInitial] = useState('')

  useEffect(() => {
    const loadProfile = () => {
      void getCurrentProfile().then((profile) => {
        setAvatarUrl(profile?.avatar_url ? `${profile.avatar_url}${profile.avatar_url.includes('?') ? '&' : '?'}v=${Date.now()}` : null)
        setInitial((profile?.first_name || profile?.username || '').slice(0, 1).toUpperCase())
      }).catch(() => undefined)
    }

    loadProfile()

    const refresh = (event: Event) => {
      const detail = (event as CustomEvent<{ avatarUrl?: string | null }>).detail
      if (detail && Object.prototype.hasOwnProperty.call(detail, 'avatarUrl')) {
        setAvatarUrl(detail.avatarUrl ?? null)
      }
      loadProfile()
    }

    window.addEventListener('kineo-profile-updated', refresh)
    window.addEventListener('focus', loadProfile)
    document.addEventListener('visibilitychange', loadProfile)
    return () => {
      window.removeEventListener('kineo-profile-updated', refresh)
      window.removeEventListener('focus', loadProfile)
      document.removeEventListener('visibilitychange', loadProfile)
    }
  }, [])

  return (
    <Link className="header-avatar-button" aria-label={isSpain?'Abrir mi cuenta':'Ouvrir mon compte'} to="/profil">
      {avatarUrl ? <img src={avatarUrl} alt={isSpain?'Mi foto de perfil':'Ma photo de profil'} /> : <span aria-hidden="true">{initial || '👤'}</span>}
      <i className="avatar-status-dot" aria-hidden="true" />
    </Link>
  )
}
