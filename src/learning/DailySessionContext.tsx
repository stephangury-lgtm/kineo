import {createContext,useCallback,useContext,useState,type ReactNode} from 'react'
type DailyState={status:'ready'|'in_progress'|'completed';answered:number;total:number}
const initial:DailyState={status:'ready',answered:0,total:10}
const Context=createContext({state:initial,update:(_next:DailyState)=>{},resumePath:null as string|null,setResumePath:(_path:string|null)=>{}})
// Memory only; never awards XP or changes server progress.
export function DailySessionProvider({children}:{children:ReactNode}){
 const [state,setState]=useState(initial)
 const [resumePath,setResumePath]=useState<string|null>(null)
 const update=useCallback((next:DailyState)=>setState(next),[])
 return <Context.Provider value={{state,update,resumePath,setResumePath}}>{children}</Context.Provider>
}
export const useDailySession=()=>useContext(Context)
