import {useState} from 'react'
export default function ApplicationShareCard({isSpain=false}:{isSpain?:boolean}){
 const [message,setMessage]=useState('')
 const url=window.location.origin+'/'
 async function copy(){try{await navigator.clipboard.writeText(url);setMessage(isSpain?'Enlace copiado.':'Lien copié.')}catch{setMessage(isSpain?'Utiliza el menú de compartir de tu navegador.':'Utilise le menu de partage de ton navigateur.')}}
 async function share(){try{if(navigator.share)await navigator.share({title:'GURIKO',text:isSpain?'Repasa y progresa con GURIKO':'Réviser et progresser avec GURIKO',url});else await copy()}catch(error){if(!(error instanceof DOMException&&error.name==='AbortError'))setMessage(isSpain?'No se puede compartir. Puedes copiar el enlace.':'Le partage est indisponible. Tu peux copier le lien.')}}
 return <section className="card application-share-card"><h2>{isSpain?'Compartir GURIKO':'Partager GURIKO'}</h2><p>{isSpain?'Invita a tus compañeros a repasar.':'Invite tes collègues à réviser.'}</p><div className="v5-actions"><button type="button" className="primary-button" onClick={()=>void share()}>{isSpain?'Compartir la aplicación':'Partager l’application'}</button><button type="button" className="secondary-button" onClick={()=>void copy()}>{isSpain?'Copiar el enlace de la aplicación':'Copier le lien de l’application'}</button></div>{message&&<p role="status">{message}</p>}</section>
}
