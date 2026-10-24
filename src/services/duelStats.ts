import type { FriendChallenge } from './challengeApi'

export function getDuelRivalries(challenges: FriendChallenge[]) {
  type Rivalry = { opponent: FriendChallenge['opponent']; latestChallengeId: string; duels: number; wins: number; losses: number; draws: number; recent: Array<'W'|'L'|'D'> }
  const rows = new Map<string, Rivalry>()
  const seen = new Set<string>()
  const completed = challenges.filter(c => c.status === 'completed' && c.challenger_score != null && c.challenged_score != null)
    .sort((a,b) => (b.completed_at || b.created_at).localeCompare(a.completed_at || a.created_at))
  for (const item of completed) {
    if (seen.has(item.id)) continue
    seen.add(item.id)
    const mine = item.direction === 'sent' ? item.challenger_score! : item.challenged_score!
    const other = item.direction === 'sent' ? item.challenged_score! : item.challenger_score!
    const row = rows.get(item.opponent.id) ?? { opponent: item.opponent, latestChallengeId: item.id, duels: 0, wins: 0, losses: 0, draws: 0, recent: [] }
    row.duels++
    if (mine > other) { row.wins++; row.recent.push('W') }
    else if (mine < other) { row.losses++; row.recent.push('L') }
    else { row.draws++; row.recent.push('D') }
    rows.set(item.opponent.id, row)
  }
  return [...rows.values()].sort((a,b) => b.duels-a.duels || b.wins-a.wins || a.opponent.id.localeCompare(b.opponent.id))
}
