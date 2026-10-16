export function selectInterface(available:boolean,defaultV5:boolean,requested:string|null,saved:string|null){
 if(!available)return false
 if(requested==='legacy'||requested==='v5')return requested==='v5'
 if(saved==='legacy'||saved==='v5')return saved==='v5'
 return defaultV5
}
