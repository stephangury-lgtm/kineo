import { useEffect, useState } from 'react'

type VersionInfo={version?:string;date?:string;branch?:string}

export default function AppVersionBadge(){
 const [info,setInfo]=useState<VersionInfo|null>(null)
 useEffect(()=>{
  let active=true
  fetch(`/version.json?v=${Date.now()}`,{cache:'no-store'})
   .then(response=>response.ok?response.json():Promise.reject(new Error('version unavailable')))
   .then((data:VersionInfo)=>{if(active)setInfo(data)})
   .catch(()=>undefined)
  return()=>{active=false}
 },[])
 if(!info?.version)return null
 return <span title={`${info.version} · ${info.date??''} · ${info.branch??''}`} style={{fontSize:10,fontWeight:800,color:'#0f766e',background:'#e7f7f4',border:'1px solid #bde7e0',borderRadius:999,padding:'3px 7px',whiteSpace:'nowrap'}}>{info.version.replace('KINEO-V2-','v')}</span>
}
