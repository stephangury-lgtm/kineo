import { supabase } from '../lib/supabase'

export type LessonPersonalState = { favorite: boolean; note: string }
export type LibraryFavorite = { id:string; title:string; summary:string|null; subject:string; year:number; created_at:string }
export type LibraryNote = { id:string; lesson_id:string; title:string; content:string; subject:string; year:number; updated_at:string }
export type PersonalLibrary = { favorites:LibraryFavorite[]; notes:LibraryNote[] }

export async function getLessonPersonalState(lessonId:string){
  const {data,error}=await supabase.rpc('get_lesson_personal_state_v1',{p_lesson_id:lessonId})
  if(error) throw error
  return data as LessonPersonalState
}

export async function toggleLessonFavorite(lessonId:string){
  const {data,error}=await supabase.rpc('toggle_lesson_favorite_v1',{p_lesson_id:lessonId})
  if(error) throw error
  return Boolean(data)
}

export async function saveLessonNote(lessonId:string,content:string){
  const {data,error}=await supabase.rpc('save_lesson_note_v1',{p_lesson_id:lessonId,p_content:content})
  if(error) throw error
  return String(data??'')
}

export async function getMyLibrary(signal?:AbortSignal){
  const query=supabase.rpc('get_my_library_v1')
  const {data,error}=await (signal?query.abortSignal(signal):query)
  if(error) throw error
  if(!data||!Array.isArray(data.favorites)||!Array.isArray(data.notes))throw new Error('Bibliothèque indisponible')
  return data as PersonalLibrary
}

