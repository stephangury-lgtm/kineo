import type {MascotState} from './mascotConfig'

// Exact viewports of the approved source board, without regenerating the character.
// Backgrounds are retained deliberately; these are not claimed to be transparent assets.
export const mascotBoard='/branding/guriko-approved-board.png'
export const mascotArtwork:Record<MascotState,string>={
 welcome:'19 499 101 111',
 thinking:'232 499 99 111',
 success:'334 499 104 111',
 retry:'445 499 104 111',
 progress:'550 499 109 111',
 'level-up':'662 499 104 111',
 streak:'771 499 105 111',
 badge:'881 499 104 111',
 'daily-challenge':'989 499 103 111',
 friends:'1093 499 190 111',
 loading:'1285 499 117 111',
 empty:'128 499 100 111',
 offline:'1407 499 114 111',
}
