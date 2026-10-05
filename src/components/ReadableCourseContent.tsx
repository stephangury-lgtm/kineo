type SourceRef={url?:string;label?:string;title?:string}

function chunkParagraph(value:string){
 const text=value.trim()
 if(!text)return[]
 if(text.length<320)return[text]
 const sentences=text.match(/[^.!?]+[.!?]+(?:\s|$)|[^.!?]+$/g)?.map(part=>part.trim()).filter(Boolean)??[text]
 const chunks:string[]=[]
 for(let i=0;i<sentences.length;i+=2)chunks.push(sentences.slice(i,i+2).join(' '))
 return chunks
}

export function ReadableCourseContent({content}:{content:string}){
 const blocks=content.split(/\n{2,}/).flatMap(chunkParagraph)
 return <div className="course-reading-body">{blocks.map((part,index)=><p className={index===0?'course-reading-lead':undefined} key={`${index}-${part.slice(0,24)}`}>{part}</p>)}</div>
}

export function CompactReferences({sources,label='Références'}:{sources:unknown;label?:string}){
 if(!Array.isArray(sources)||sources.length===0)return null
 const refs=sources.filter(Boolean) as Array<string|SourceRef>
 if(refs.length===0)return null
 return <details className="course-reference-details">
  <summary>↗ {label} <span>{refs.length}</span></summary>
  <div className="course-reference-list">{refs.map((source,index)=>{
   if(typeof source==='string')return <span key={`${source}-${index}`}>{source}</span>
   const title=source.label||source.title||'Référence externe'
   return source.url?<a key={`${title}-${index}`} href={source.url} target="_blank" rel="noreferrer">{title}</a>:<span key={`${title}-${index}`}>{title}</span>
  })}</div>
 </details>
}
