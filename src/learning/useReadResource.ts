import {useEffect,useState} from 'react'
// A slow optional section must not block the rest of the learning screen.
export function useReadResource<T>(loader:()=>Promise<T>,key:string){
 const [attempt,setAttempt]=useState(0)
 const [state,setState]=useState<{loading:boolean;data:T|undefined;error:boolean}>({loading:true,data:undefined,error:false})
 useEffect(()=>{
  let alive=true
  setState({loading:true,data:undefined,error:false})
  const timer=window.setTimeout(()=>{if(alive){alive=false;setState({loading:false,data:undefined,error:true})}},12000)
  loader().then(data=>{if(alive)setState({loading:false,data,error:false})}).catch(()=>{if(alive)setState({loading:false,data:undefined,error:true})}).finally(()=>window.clearTimeout(timer))
  return()=>{alive=false;window.clearTimeout(timer)}
 },[loader,key,attempt])
 return {...state,retry:()=>setAttempt(value=>value+1)}
}
