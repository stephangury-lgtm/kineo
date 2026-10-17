import type {CurriculumAnswerResult} from '../services/programCatalogApi'
export type DailySnapshot={ids:string[];index:number;selected:string;result:CurriculumAnswerResult|null;correctCount:number}
export const DAILY_PREFIX='leryko_daily_v1:'
export function readDailySnapshot(key:string):DailySnapshot|null{
 try{
  const value=JSON.parse(sessionStorage.getItem(key)??'null')
  if(!value||!Array.isArray(value.ids)||!value.ids.length||value.ids.length>10||!value.ids.every((id:unknown)=>typeof id==='string')||new Set(value.ids).size!==value.ids.length)return null
  if(!Number.isInteger(value.index)||value.index<0||value.index>value.ids.length||typeof value.selected!=='string'||value.selected.length>10000)return null
  if(!Number.isInteger(value.correctCount)||value.correctCount<0||value.correctCount>value.index+(value.result?1:0)||value.correctCount>value.ids.length)return null
  if(value.result!==null&&(!value.result||typeof value.result.correct!=='boolean'||(value.result.explanation!=null&&typeof value.result.explanation!=='string')||(value.result.correct_answer!=null&&typeof value.result.correct_answer!=='string')))return null
  return value
 }catch{return null}
}
export function clearDailySnapshots(){try{for(const key of Object.keys(sessionStorage))if(key.startsWith(DAILY_PREFIX))sessionStorage.removeItem(key)}catch{/* Storage can be disabled. */}}
