import type { CSSProperties, ReactNode } from 'react'
import type { ProgramId } from '../curriculum/programs'
import { mascotMessage, mascotThemes, type MascotState } from './mascotConfig'

export type MascotProps = {
  state: MascotState
  program: ProgramId
  size?: 'small' | 'medium' | 'large'
  decorative?: boolean
  className?: string
  children?: ReactNode
}

/** Accessible mascot with per-state illustrations and a resilient fallback. */
export default function Mascot({ state, program, size = 'medium', decorative = false, className = '', children }: MascotProps) {
  const theme = mascotThemes[program]
  const message = mascotMessage(state, program)
  const style = {
    '--mascot-primary': theme.primary,
    '--mascot-secondary': theme.secondary,
    '--mascot-accent': theme.accent,
  } as CSSProperties
  return (
    <figure className={['guriko-mascot', 'guriko-mascot--' + size, className].filter(Boolean).join(' ')} style={style}
      role={decorative ? undefined : 'img'} aria-label={decorative ? undefined : message} aria-hidden={decorative || undefined}>
      <span className="guriko-mascot__symbol" aria-hidden="true"><img className="guriko-mascot__image" src={`/branding/mascot/${state}.webp`} alt="" loading="lazy" onError={(event) => { event.currentTarget.hidden = true }} /><span className="guriko-mascot__fallback">✦</span></span>
      {!decorative && <figcaption className="guriko-mascot__caption">{children ?? message}</figcaption>}
    </figure>
  )
}
