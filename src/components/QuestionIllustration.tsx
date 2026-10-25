import {useId,useRef} from 'react'
import './QuestionIllustration.css'

export default function QuestionIllustration({src,title,page}:{src:string;title:string;page:string}){
 const dialog=useRef<HTMLDialogElement>(null),id=useId()
 return <figure className="question-anatomy"><img className="question-image" src={src} alt="Schéma anatomique du cours associé à la question"/><figcaption>{title} · p. {page}</figcaption><button type="button" className="secondary-button compact-button" onClick={()=>dialog.current?.showModal()}>Agrandir le schéma</button><dialog ref={dialog} className="question-anatomy-dialog" aria-labelledby={id}><header><h2 id={id}>Schéma anatomique</h2><button type="button" className="secondary-button compact-button" onClick={()=>dialog.current?.close()}>Fermer</button></header><img src={src} alt="Schéma anatomique agrandi, avec ses repères d’orientation"/><p>{title} · p. {page}</p></dialog></figure>
}
