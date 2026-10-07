import React from 'react'
import ReactDOM from 'react-dom/client'
import { BrowserRouter } from 'react-router-dom'
import App from './App'
import AppErrorBoundary from './components/AppErrorBoundary'
import { reportClientError } from './services/clientErrorApi'
import './styles.css'
import './social.css'
import './visual-quiz.css'
import './accessibility.css'
import './compact-ui.css'
import './pwa-mobile.css'

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <AppErrorBoundary>
      <BrowserRouter>
        <App />
      </BrowserRouter>
    </AppErrorBoundary>
  </React.StrictMode>,
)

window.addEventListener('vite:preloadError',(event)=>{
  if(navigator.onLine===false)return
  const key='kineo_chunk_recovery_at'
  const last=Number(sessionStorage.getItem(key)??0)
  const now=Date.now()
  if(now-last<30_000)return
  event.preventDefault()
  sessionStorage.setItem(key,String(now))
  window.location.reload()
})

window.addEventListener('error',(event)=>{
 const message=event.error instanceof Error?event.error.message:event.message
 if(!message)return
 void reportClientError({message:`Window error: ${message}`})
})

window.addEventListener('unhandledrejection',(event)=>{
 const reason=event.reason
 const message=reason instanceof Error?reason.message:typeof reason==='string'?reason:'Unhandled promise rejection'
 void reportClientError({message:`Promise rejection: ${message}`})
})

// Friend challenges are score-based duels, not corrective exercises.
// Once an answer has been submitted (right or wrong), keep the selected state
// visible briefly, then move on automatically. Wrong answers simply score 0.
const challengeRoot = document.getElementById('root')
if (challengeRoot && 'MutationObserver' in window) {
  let advanceTimer: number | null = null
  const maybeAdvanceChallenge = () => {
    const params = new URLSearchParams(window.location.search)
    if (params.get('mode') !== 'challenge') return

    const resultBox = document.querySelector<HTMLElement>('.quiz-card .result-box')
    if (!resultBox || resultBox.dataset.challengeAdvance === 'scheduled') return
    const nextButton = resultBox.querySelector<HTMLButtonElement>('button.primary-button')
    if (!nextButton || nextButton.disabled) return

    resultBox.dataset.challengeAdvance = 'scheduled'
    if (advanceTimer !== null) window.clearTimeout(advanceTimer)
    advanceTimer = window.setTimeout(() => {
      if (document.contains(nextButton) && !nextButton.disabled) nextButton.click()
      advanceTimer = null
    }, 900)
  }

  const challengeObserver = new MutationObserver(maybeAdvanceChallenge)
  challengeObserver.observe(challengeRoot, { childList: true, subtree: true })
}

if ('serviceWorker' in navigator) {
  window.addEventListener('load', () => {
    const hadControllerAtLoad = Boolean(navigator.serviceWorker.controller)
    navigator.serviceWorker.register('/sw.js').then((registration) => {
      const update = () => registration.update().catch(() => undefined)
      window.addEventListener('online', update)
      document.addEventListener('visibilitychange', () => {
        if (document.visibilityState === 'visible') update()
      })
      window.setInterval(update, 15 * 60 * 1000)
    }).catch(() => undefined)

    let refreshing = false
    navigator.serviceWorker.addEventListener('controllerchange', () => {
      // Do not reload when the service worker takes control for the very first time.
      // A first-install reload can abort an in-flight login or form submission.
      if (!hadControllerAtLoad || refreshing) return
      refreshing = true
      window.location.reload()
    })
  })
}
