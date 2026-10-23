import type { ProgramId } from '../curriculum/programs'

/** Brand-neutral mascot states: usable while the final brand name is being cleared. */
export const mascotStates = [
  'welcome', 'thinking', 'success', 'retry', 'progress', 'level-up',
  'streak', 'badge', 'daily-challenge', 'friends', 'loading', 'empty', 'offline',
] as const
export type MascotState = typeof mascotStates[number]

export type MascotTheme = { primary: string; secondary: string; accent: string; label: string }
export const mascotThemes: Record<ProgramId, MascotTheme> = {
  'kineo-fr': { primary: '#177D87', secondary: '#E0F5F3', accent: '#F49A72', label: 'Kiné France' },
  'kineo-es': { primary: '#4D68B8', secondary: '#E8EDFF', accent: '#F3AB74', label: 'Fisioterapia España' },
  'ifsi-fr': { primary: '#7A58A8', secondary: '#F1EAF9', accent: '#EFA18B', label: 'IFSI France' },
}

const messages: Record<MascotState, {fr: string; es: string}> = {
  welcome: {fr:'Prêt à progresser ?',es:'¿Listo para avanzar?'},
  thinking: {fr:'Prends le temps de réfléchir.',es:'Tómate tu tiempo para pensar.'},
  success: {fr:'Bien joué !',es:'¡Bien hecho!'},
  retry: {fr:'On réessaie ensemble ?',es:'¿Lo intentamos de nuevo?'},
  progress: {fr:'Tu avances à ton rythme.',es:'Avanzas a tu ritmo.'},
  'level-up': {fr:'Nouveau niveau atteint !',es:'¡Has subido de nivel!'},
  streak: {fr:'Belle régularité !',es:'¡Qué constancia!'},
  badge: {fr:'Un badge de plus !',es:'¡Una insignia más!'},
  'daily-challenge': {fr:'Ton défi du jour t’attend.',es:'Te espera el reto del día.'},
  friends: {fr:'Progresser ensemble, c’est motivant.',es:'Aprender juntos motiva.'},
  loading: {fr:'Un instant…',es:'Un momento…'},
  empty: {fr:'Tes prochaines découvertes arrivent.',es:'Pronto llegarán nuevos contenidos.'},
  offline: {fr:'Connexion indisponible pour le moment.',es:'Conexión no disponible por ahora.'},
}

export function mascotMessage(state: MascotState, program: ProgramId): string {
  return messages[state][program === 'kineo-es' ? 'es' : 'fr']
}
