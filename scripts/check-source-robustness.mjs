import fs from 'node:fs'

const read=path=>fs.readFileSync(path,'utf8')
const assert=(condition,message)=>{if(!condition)throw new Error(message)}

const app=read('src/App.tsx')
const main=read('src/main.tsx')
const social=read('src/services/socialApi.ts')
const landing=read('src/pages/ProgramLandingPage.tsx')
const foundations=read('src/pages/FoundationsPage.tsx')
const topic=read('src/pages/CurriculumTopicPage.tsx')

assert(main.includes('<AppErrorBoundary>'),'Global React error boundary is missing')
assert(main.includes("window.addEventListener('unhandledrejection'"),'Unhandled promise rejection reporting is missing')
assert(main.includes("window.addEventListener('vite:preloadError'"),'Stale dynamic chunk recovery is missing')
assert(app.includes('<FeedbackButton/>'),'Feedback reporting must stay available for every curriculum')
assert(app.includes("isKineoFrance?<RevisionContentGate><RevisionPage/></RevisionContentGate>:<Navigate to=\"/fondamentaux\" replace/>"),'Non-France revision routing drifted from cumulative revision')
assert(social.includes("get_friend_leaderboard_v2"),'Leaderboard must use the program/level-scoped RPC')
const challenges=read('src/services/challengeApi.ts')
assert(challenges.includes("get_friend_challenges_v3"),'France challenges must use the authenticated v3 reader')
assert(!challenges.includes("get_friend_challenges_v2'"),'Frontend must not call retired friend challenge v2')
assert(social.includes("{p_program_id:programId}"),'Leaderboard must pass the active program')
assert(landing.includes('isProgramLevelUnlocked'),'Curriculum level locking helper is not used')
assert(!landing.includes('saveProgramLevel('),'Parcours must never change the assigned academic level')
assert(foundations.includes('async function restart()'),'Cumulative revision replay must reset and reload a session')
assert(foundations.includes('getFoundationQuestions(program.id,mode,sessionCount'),'Cumulative revision must request a fresh validated pool')
assert(foundations.includes('sampleBalancedByUnit'),'Semester revision must stay balanced across units')
assert(foundations.includes('if(scope.levelCode)return sampleBalancedByUnit(pool,count)'),'Semester scope must use balanced sampling')
assert(topic.includes('function restartQuiz()'),'Topic quiz replay must explicitly reset local state')
assert(topic.includes("setChecked({})"),'Topic quiz replay must clear completion state')

console.log('Critical source robustness invariants passed')
