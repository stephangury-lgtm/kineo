import { Component, type ErrorInfo, type ReactNode } from 'react'
import { supabase } from '../lib/supabase'

type Props={children:ReactNode}
type State={hasError:boolean}

export default class AppErrorBoundary extends Component<Props,State>{
 state:State={hasError:false}
 static getDerivedStateFromError(){return{hasError:true}}
 componentDidCatch(error:Error,info:ErrorInfo){
  console.error('Kineo render error',error,info)
  void (async()=>{
   try{
    await supabase.rpc('report_client_error_v1',{
     p_message:error.message||'React render error',
     p_component_stack:info.componentStack??null,
     p_page_path:`${window.location.pathname}${window.location.search}`,
     p_app_version:null,
    })
   }catch{
    // Reporting must never mask the original recovery screen.
   }
  })()
 }
 render(){
  if(this.state.hasError)return <main className="content"><section className="card centered"><div className="completion-icon">🛠️</div><p className="eyebrow">Kineo</p><h1>Un écran a rencontré un problème</h1><p>Ta progression est enregistrée sur ton compte. Recharge l’application pour reprendre.</p><div className="completion-actions"><button className="primary-button" onClick={()=>window.location.reload()}>Recharger Kineo</button><button className="secondary-button" onClick={()=>{window.location.href='/'}}>Retour à l’accueil</button></div></section></main>
  return this.props.children
 }
}
