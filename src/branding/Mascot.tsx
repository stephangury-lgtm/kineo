import type { CSSProperties, ReactNode } from 'react'
import type { ProgramId } from '../curriculum/programs'
import { mascotMessage, mascotThemes, type MascotState } from './mascotConfig'
import {mascotArtwork,mascotBoard} from './mascotArtwork'
import './mascot.css'

export type MascotProps = {
  state: MascotState
  program: ProgramId
  size?: 'small' | 'medium' | 'large'
  decorative?: boolean
  className?: string
  children?: ReactNode
  /** Only provide a URL once the approved asset exists in public/. */
  assetSrc?: string
}

/** Accessible mascot with per-state illustrations and a resilient fallback. */
export default function Mascot({ state, program, size = 'medium', decorative = false, className = '', children, assetSrc }: MascotProps) {
  const theme = mascotThemes[program]
  const message = mascotMessage(state, program)
  const style = {
    '--mascot-primary': 'var(--program-primary, ' + theme.primary + ')',
    '--mascot-secondary': 'var(--program-soft, ' + theme.secondary + ')',
    '--mascot-accent': theme.accent,
  } as CSSProperties
  return (
    <figure data-mascot-state={state} className={['guriko-mascot', 'guriko-mascot--' + size, className].filter(Boolean).join(' ')} style={style}
      aria-hidden={decorative || undefined}>
      <span className="guriko-mascot__symbol" role={decorative ? undefined : "img"} aria-label={decorative ? undefined : message} aria-hidden={decorative || undefined}>{assetSrc ? <img className="guriko-mascot__image" src={assetSrc} alt="" loading="lazy" onError={(event) => { event.currentTarget.hidden = true }} /> : <svg className="guriko-mascot__image" viewBox={mascotArtwork[state]} aria-hidden="true"><image href={mascotBoard} width="1536" height="1024" /></svg>}<span className="guriko-mascot__fallback">✦</span></span>
      {!decorative && <figcaption className="guriko-mascot__caption">{children ?? message}</figcaption>}
    </figure>
  )
}
