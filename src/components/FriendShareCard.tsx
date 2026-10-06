import { useEffect,useMemo,useState } from 'react'
import { Link } from 'react-router-dom'
import QRCode from 'qrcode'

export default function FriendShareCard({username,isSpain=false}:{username:string;isSpain?:boolean}){
 const [message,setMessage]=useState<string|null>(null)
 const [qrUrl,setQrUrl]=useState<string>('')
 const inviteUrl=useMemo(()=>`${window.location.origin}/amis?add=${encodeURIComponent(username)}`,[username])
 useEffect(()=>{
  let active=true
  QRCode.toDataURL(inviteUrl,{width:220,margin:1,errorCorrectionLevel:'M'})
   .then(url=>{if(active)setQrUrl(url)})
   .catch(()=>{if(active)setQrUrl('')})
  return()=>{active=false}
 },[inviteUrl])
 async function copy(value:string,label:string){
  try{await navigator.clipboard.writeText(value);setMessage(`${label} ${isSpain?'copiado ✓':'copié ✓'}`)}
  catch{setMessage(isSpain?'No se pudo copiar.':'Impossible de copier.')}
 }
 async function share(){
  const text=isSpain?`Añádeme en Kineo: @${username}`:`Ajoute-moi sur Kineo : @${username}`
  try{
   if(navigator.share){await navigator.share({title:'Kineo',text,url:inviteUrl});setMessage(isSpain?'Invitación compartida ✓':'Invitation partagée ✓')}
   else await copy(inviteUrl,isSpain?'Enlace':'Lien')
  }catch(error){if(error instanceof DOMException&&error.name==='AbortError')return;setMessage(isSpain?'No se pudo compartir.':'Impossible de partager.')}
 }
 return <section className="card friend-share-card"><div className="section-heading"><div><p className="eyebrow">{isSpain?'Añadir amigos':'Ajouter des amis'}</p><h2>{isSpain?'Mi tarjeta de amigo':'Ma carte ami'}</h2></div><span>🤝</span></div><p>{isSpain?'Comparte tu alias o este QR para que otro estudiante pueda encontrarte rápidamente.':'Partage ton pseudo ou ce QR code pour qu’un autre étudiant puisse te retrouver rapidement.'}</p><div className="friend-share-layout"><div className="friend-identity"><span className="friend-handle">@{username}</span><small>{isSpain?'Alias público Kineo':'Pseudo public Kineo'}</small><div className="friend-share-actions"><button className="primary-button" type="button" onClick={()=>void share()}>{isSpain?'Compartir':'Partager'}</button><button className="secondary-button" type="button" onClick={()=>void copy(username,isSpain?'Alias':'Pseudo')}>{isSpain?'Copiar alias':'Copier le pseudo'}</button><button className="secondary-button" type="button" onClick={()=>void copy(inviteUrl,isSpain?'Enlace':'Lien')}>{isSpain?'Copiar enlace':'Copier le lien'}</button></div></div><div className="friend-qr-wrap">{qrUrl?<img className="friend-qr" src={qrUrl} alt={isSpain?'Código QR para añadirme como amigo en Kineo':'QR code pour m’ajouter comme ami sur Kineo'}/>:<div className="friend-qr" aria-busy="true" aria-label={isSpain?'Generando código QR':'Génération du QR code'} />}<small>{isSpain?'Escanear para abrir Kineo':'Scanner pour ouvrir Kineo'}</small></div></div>{message&&<p className="feedback" aria-live="polite">{message}</p>}<Link className="text-link" to={`/amis?add=${encodeURIComponent(username)}`}>{isSpain?'Ver mis amigos y solicitudes':'Voir mes amis et invitations'}</Link></section>
}
