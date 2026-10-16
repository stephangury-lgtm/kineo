import {useState} from 'react'
export default function ApplicationShareCard(){
 const [message,setMessage]=useState('')
 const url=window.location.origin+'/'
 async function copy(){try{await navigator.clipboard.writeText(url);setMessage('Lien copié.')}catch{setMessage('Sélectionne le lien ci-dessous pour le copier manuellement.')}}
 async function share(){try{if(navigator.share)await navigator.share({title:'Leryko',text:'Réviser et progresser avec Leryko',url});else await copy()}catch(error){if(!(error instanceof DOMException&&error.name==='AbortError'))setMessage('Le partage est indisponible. Tu peux copier le lien.')}}
 return <section className="card"><h2>Partager Leryko</h2><p>Ce lien ouvre l’application. Chaque étudiant utilise son compte et ses accès habituels.</p><label>Lien public de l’application<input readOnly value={url} onFocus={event=>event.currentTarget.select()}/></label><div className="v5-actions"><button className="primary-button" onClick={()=>void share()}>Partager l’application</button><button className="secondary-button" onClick={()=>void copy()}>Copier le lien de l’application</button></div><p role="status">{message}</p></section>
}
