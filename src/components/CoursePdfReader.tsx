import {useEffect,useRef,useState} from 'react'
import {getDocument,GlobalWorkerOptions,type PDFDocumentProxy} from 'pdfjs-dist'
import workerUrl from 'pdfjs-dist/build/pdf.worker.min.mjs?url'
import './CoursePdfReader.css'

GlobalWorkerOptions.workerSrc=workerUrl

export default function CoursePdfReader({url,title,isSpain=false}:{url:string;title:string;isSpain?:boolean}){
 const [pdf,setPdf]=useState<PDFDocumentProxy|null>(null)
 const [page,setPage]=useState(1),[zoom,setZoom]=useState(1),[width,setWidth]=useState(300)
 const [error,setError]=useState(false),[loading,setLoading]=useState(true),[text,setText]=useState('')
 const canvas=useRef<HTMLCanvasElement>(null),container=useRef<HTMLDivElement>(null)
 useEffect(()=>{
  let active=true
  setPdf(null);setPage(1);setZoom(1);setError(false);setLoading(true);setText('')
  const task=getDocument({url,cMapUrl:'/pdf-assets/cmaps/',cMapPacked:true,standardFontDataUrl:'/pdf-assets/standard_fonts/',wasmUrl:'/pdf-assets/wasm/'})
  const timer=window.setTimeout(()=>{if(active){active=false;setError(true);setLoading(false);void task.destroy()}},30000)
  task.promise.then(value=>{if(active)setPdf(value)}).catch(()=>{if(active){setError(true);setLoading(false)}}).finally(()=>window.clearTimeout(timer))
  return()=>{active=false;window.clearTimeout(timer);void task.destroy()}
 },[url])
 useEffect(()=>{
  const element=container.current
  if(!element)return
  const observer=new ResizeObserver(entries=>setWidth(Math.max(1,entries[0].contentRect.width)))
  observer.observe(element)
  return()=>observer.disconnect()
 },[])
 useEffect(()=>{
  if(!pdf)return
  let active=true
  let render:ReturnType<Awaited<ReturnType<PDFDocumentProxy['getPage']>>['render']>|undefined
  setLoading(true);setError(false);setText('')
  void pdf.getPage(page).then(async sheet=>{
   if(!active||!canvas.current)return
   const viewport=sheet.getViewport({scale:width/sheet.getViewport({scale:1}).width*zoom})
   const ratio=Math.min(window.devicePixelRatio||1,2)
   canvas.current.width=Math.ceil(viewport.width*ratio);canvas.current.height=Math.ceil(viewport.height*ratio)
   canvas.current.style.width=`${viewport.width}px`;canvas.current.style.height=`${viewport.height}px`
   render=sheet.render({canvas:canvas.current,viewport,transform:ratio===1?undefined:[ratio,0,0,ratio,0,0]})
   await render.promise
   if(!active)return
   setLoading(false)
   const content=await sheet.getTextContent()
   if(active)setText(content.items.map(item=>'str' in item?item.str:'').join(' '))
  }).catch(()=>{if(active){setError(true);setLoading(false)}})
  return()=>{active=false;render?.cancel()}
 },[pdf,page,width,zoom])
 return <div className="course-pdf-reader" ref={container}>
  {pdf&&<div className="pdf-toolbar" role="group" aria-label={isSpain?'Navegación del PDF':'Navigation du PDF'}>
   <button type="button" disabled={page<=1} onClick={()=>setPage(value=>value-1)}>{isSpain?'Anterior':'Précédente'}</button>
   <span aria-live="polite">{isSpain?'Página':'Page'} {page} / {pdf.numPages}</span>
   <button type="button" disabled={page>=pdf.numPages} onClick={()=>setPage(value=>value+1)}>{isSpain?'Siguiente':'Suivante'}</button>
   <label>{isSpain?'Tamaño':'Taille'} <select value={zoom} onChange={event=>setZoom(Number(event.target.value))}><option value={1}>{isSpain?'Ancho de página':'Largeur de page'}</option><option value={1.5}>150 %</option><option value={2}>200 %</option></select></label>
  </div>}
  {loading&&<p role="status">{isSpain?'Cargando la página…':'Chargement de la page…'}</p>}
  {error&&<p role="alert">{isSpain?'No se puede mostrar esta página. Actualiza el acceso o abre el PDF.':'Cette page ne peut pas être affichée. Actualise l’accès ou utilise « Ouvrir le PDF ».'}</p>}
  <div className="pdf-page-scroll" aria-busy={loading}><canvas ref={canvas} role="img" aria-label={`${title} — page ${page}`} hidden={loading||error}/></div>
  {text&&<details className="pdf-page-text"><summary>{isSpain?'Texto de la página':'Texte de la page'}</summary><p>{text}</p></details>}
 </div>
}
