import './brand-identity.css'
/** Approved icon plus plain-text application name; no new logo artwork. */
export default function BrandIdentity({className=''}:{className?:string}){
 return <span className={'guriko-identity '+className} role="img" aria-label="GURIKO"><img src="/icons/guriko-192.png" alt="" width="40" height="40"/><span aria-hidden="true">GURIKO</span></span>
}
