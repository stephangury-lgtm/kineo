import type { FriendChallenge } from './challengeApi'

export function getDuelMessagePresets(duel: FriendChallenge, isSpain: boolean): string[] {
 const mine = duel.direction === 'sent' ? duel.challenger_score : duel.challenged_score
 const other = duel.direction === 'sent' ? duel.challenged_score : duel.challenger_score
 if (mine == null || other == null) return []
 if (mine > other) return isSpain ? [
  'Un punto para mí, una idea más para los dos. ¿Repetimos? 📚',
  'Disfruto mi pequeña victoria… ¡y repaso para la siguiente! 😄',
  'Buen duelo. ¿Me das la oportunidad de presumir cinco minutos antes de la revancha? 😉',
 ] : [
  'Un point pour moi, une notion de plus pour nous. On remet ça ? 📚',
  'Je savoure ma petite victoire… et je révise pour la suivante ! 😄',
  'Beau duel ! Tu me laisses cinq minutes pour frimer avant la revanche ? 😉',
 ]
 if (mine < other) return isSpain ? [
  'Tú ganas la ronda, yo gano una ficha para repasar 😄 ¿Revancha?',
  'Acepto la corrección… ¡y preparo la revancha! 📚',
  'Bien jugado. Mis neuronas han pedido una segunda oportunidad 😉',
 ] : [
  'Tu as gagné la manche, j’ai gagné une fiche à réviser 😄 Revanche ?',
  'Je prends la correction… et je prépare la revanche ! 📚',
  'Bien joué ! Mes neurones réclament une deuxième chance 😉',
 ]
 return isSpain ? [
  'Empate: nuestras neuronas han repasado juntas 🤝',
  'Mismo resultado, mismas ganas. ¿Una revancha para decidir? 📚',
  'Hoy compartimos el podio. ¿Otra ronda? 😄',
 ] : [
  'Match nul : nos neurones ont visiblement révisé ensemble 🤝',
  'Même score, même détermination. Une revanche pour nous départager ? 📚',
  'Aujourd’hui, on partage le podium. Une autre manche ? 😄',
 ]
}
