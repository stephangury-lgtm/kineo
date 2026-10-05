type SourceRef={url?:string;label?:string;title?:string}

type CourseBlock=
 |{type:'heading';text:string}
 |{type:'paragraph';text:string;lead:boolean}
 |{type:'list';items:string[]}

function chunkParagraph(value:string){
 const text=value.trim()
 if(!text)return[]
 if(text.length<320)return[text]
 const sentences=text.match(/[^.!?]+[.!?]+(?:\s|$)|[^.!?]+$/g)?.map(part=>part.trim()).filter(Boolean)??[text]
 const chunks:string[]=[]
 for(let i=0;i<sentences.length;i+=2)chunks.push(sentences.slice(i,i+2).join(' '))
 return chunks
}

function parseContent(content:string){
 const raw=content.split(/\n{2,}/).map(block=>block.trim()).filter(Boolean)
 const blocks:CourseBlock[]=[]
 let paragraphCount=0
 for(const block of raw){
  const lines=block.split('\n').map(line=>line.trim()).filter(Boolean)
  if(lines.length===1&&/^(#{1,3}\s+|[A-ZÀ-ÖØ-Ý][^.!?]{0,70}:$)/.test(lines[0])){
   blocks.push({type:'heading',text:lines[0].replace(/^#{1,3}\s+/,'').replace(/:$/,'')})
   continue
  }
  if(lines.every(line=>/^[-•]\s+/.test(line))){
   blocks.push({type:'list',items:lines.map(line=>line.replace(/^[-•]\s+/,''))})
   continue
  }
  for(const paragraph of chunkParagraph(block)){
   blocks.push({type:'paragraph',text:paragraph,lead:paragraphCount===0})
   paragraphCount+=1
  }
 }
 return blocks
}

export function ReadableCourseContent({content}:{content:string}){
 const blocks=parseContent(content)
 return <div className="course-reading-body">{blocks.map((block,index)=>{
  if(block.type==='heading')return <h3 className="course-reading-heading" key={`${index}-${block.text.slice(0,24)}`}>{block.text}</h3>
  if(block.type==='list')return <ul className="course-reading-list" key={`${index}-${block.items[0]?.slice(0,24)??'list'}`}>{block.items.map((item,itemIndex)=><li key={`${itemIndex}-${item.slice(0,24)}`}>{item}</li>)}</ul>
  return <p className={block.lead?'course-reading-lead':undefined} key={`${index}-${block.text.slice(0,24)}`}>{block.text}</p>
 })}</div>
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
