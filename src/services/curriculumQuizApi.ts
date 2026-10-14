import { supabase } from '../lib/supabase'
import type { CurriculumQuizQuestion } from './programCatalogApi'

// Fetch every page: a semester's validated pool can exceed the Data API row cap.
export async function getSafeCurriculumQuestions(topicIds:string[]):Promise<CurriculumQuizQuestion[]>{
 const ids=[...new Set(topicIds)]
 const questions:CurriculumQuizQuestion[]=[]
 const pageSize=500
 for(let offset=0;offset<ids.length;offset+=200){
  const topics=ids.slice(offset,offset+200)
  for(let from=0;;from+=pageSize){
   const {data,error}=await supabase.rpc('get_curriculum_quiz_questions_v1',{p_topic_ids:topics}).range(from,from+pageSize-1)
   if(error)throw error
   const page=(data??[]) as CurriculumQuizQuestion[]
   questions.push(...page)
   if(page.length<pageSize)break
  }
 }
 return questions
}
