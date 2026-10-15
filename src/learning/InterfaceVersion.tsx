import {createContext,useContext,useState,type ReactNode} from 'react'

const storageKey='leryko-interface-preview'
const VersionContext=createContext({v5:false,available:false,setV5:(_enabled:boolean)=>{}})
export function InterfaceVersionProvider({children}:{children:ReactNode}){
 const available=(import.meta as ImportMeta&{env:Record<string,string>}).env.VITE_ENABLE_V5_PREVIEW==='true'
 const [selected,setSelected]=useState(()=>{
  if(!available)return false
  try{return new URLSearchParams(window.location.search).get('ui')==='v5'||sessionStorage.getItem(storageKey)==='v5'}catch{return false}
 })
 const setV5=(enabled:boolean)=>{if(!available)return;setSelected(enabled);try{sessionStorage.setItem(storageKey,enabled?'v5':'legacy')}catch{};const url=new URL(window.location.href);url.searchParams.delete('ui');window.history.replaceState(window.history.state,'',url)}
 return <VersionContext.Provider value={{v5:available&&selected,available,setV5}}>{children}</VersionContext.Provider>
}
export const useInterfaceVersion=()=>useContext(VersionContext)
export function InterfaceVersionSwitch(){
 const {v5,available,setV5}=useInterfaceVersion()
 if(!available)return null
 return <div className="v5-preview-switch" role="group" aria-label="Version de l’interface"><span>Prévisualisation de l’interface · les actions utilisent le backend configuré</span><button type="button" aria-pressed={!v5} onClick={()=>setV5(false)}>Interface actuelle</button><button type="button" aria-pressed={v5} onClick={()=>setV5(true)}>Interface V5</button></div>
}
