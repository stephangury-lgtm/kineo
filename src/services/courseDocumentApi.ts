import { supabase } from '../lib/supabase'

export type CourseDocument = {
 id:string
 title:string
 file_name:string
 storage_path:string
 mime_type:string
 file_size:number|null
}

export async function getCourseDocument(id:string){
 const {data,error}=await supabase.rpc('get_course_document_v1',{p_document_id:id})
 if(error)throw error
 if(!data?.storage_path)throw new Error('Ce support de cours n’est pas disponible.')
 const {data:access,error:accessError}=await supabase.storage.from('documents').createSignedUrl(data.storage_path,900)
 if(accessError||!access?.signedUrl)throw accessError??new Error('Impossible d’ouvrir ce support.')
 return {...data,signedUrl:access.signedUrl} as CourseDocument&{signedUrl:string}
}

export async function getCourseDocuments(){
 const {data,error}=await supabase.rpc('get_course_documents_v1')
 if(error)throw error
 return (data??[]) as Array<Pick<CourseDocument,'id'|'title'|'file_name'|'file_size'>>
}
