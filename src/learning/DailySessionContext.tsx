import {createContext,useCallback,useContext,useState,type ReactNode} from 'react'
import {useAuthenticatedStudent} from '../auth/AuthenticatedStudent'
import {getCurrentProgram} from '../curriculum/programs'
import {useInterfaceVersion} from './InterfaceVersion'
import {DAILY_PREFIX,readDailySnapshot,type DailySnapshot} from './daily-session-storage'
type DailyState={status:'ready'|'in_progress'|'completed';answered:number;total:number}
const initial:DailyState={status:'ready',answered:0,total:10}
const Context=createContext({state:initial,update:(_next:DailyState)=>{},resumePath:null as string|null,setResumePath:(_path:string|null)=>{},snapshot:null as DailySnapshot|null,saveSnapshot:(_next:DailySnapshot|null)=>{},storageAvailable:true})
export function DailySessionProvider({children}:{children:ReactNode}){
 const user=useAuthenticatedStudent(),program=getCurrentProgram(),{v5}=useInterfaceVersion(),now=new Date()
 const day=[now.getFullYear(),now.getMonth()+1,now.getDate()].join('-')
 const scope=DAILY_PREFIX+[user,program.id,localStorage.getItem(`healthapp_level_${program.id}`),localStorage.getItem(`healthapp_curriculum_${program.id}`),day].join(':')
 return <SessionScope key={scope+v5} storageKey={v5&&program.id!=='kineo-fr'&&user?scope:null}>{children}</SessionScope>
}
function SessionScope({children,storageKey}:{children:ReactNode;storageKey:string|null}){
 const [snapshot,setSnapshot]=useState<DailySnapshot|null>(()=>storageKey?readDailySnapshot(storageKey):null)
 const [state,setState]=useState<DailyState>(()=>snapshot?{status:snapshot.index>=snapshot.ids.length?'completed':'in_progress',answered:Math.min(snapshot.index+(snapshot.result?1:0),snapshot.ids.length),total:snapshot.ids.length}:initial)
 const [resumePath,setResumePath]=useState<string|null>(null)
 const [storageAvailable,setStorageAvailable]=useState(true)
 const update=useCallback((next:DailyState)=>setState(next),[])
 const saveSnapshot=useCallback((next:DailySnapshot|null)=>{
  setSnapshot(next)
  if(!next)setState(initial)
  if(storageKey)try{if(next)sessionStorage.setItem(storageKey,JSON.stringify(next));else sessionStorage.removeItem(storageKey);setStorageAvailable(true)}catch{setStorageAvailable(false)}
 },[storageKey])
 return <Context.Provider value={{state,update,resumePath,setResumePath,snapshot,saveSnapshot,storageAvailable}}>{children}</Context.Provider>
}
export const useDailySession=()=>useContext(Context)
