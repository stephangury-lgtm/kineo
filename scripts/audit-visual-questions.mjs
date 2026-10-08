import fs from 'node:fs'
import path from 'node:path'
import { createClient } from '@supabase/supabase-js'
const url=process.env.SUPABASE_URL
const key=process.env.SUPABASE_SERVICE_ROLE_KEY
if(!url||!key)throw Error('Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY')
const supabase=createClient(url,key,{auth:{persistSession:false}})
const {data,error}=await supabase.from('questions').select('id,type,question_text,image_url,metadata,validation_status,is_published').in('type',['hotspot','image']).eq('is_published',false)
if(error)throw error
const report=[]
for(const q of data??[]){
 const source=q.image_url??''
 const local=source.startsWith('/quiz-assets/')
 const absolute=local?path.resolve('public',source.slice(1)):null
 const exists=local?fs.existsSync(absolute):source.startsWith('data:image/')
 const meta=q.metadata??{}
 const targets=q.type==='hotspot'?[meta.hotspot_v2??meta.hotspot]:meta.label_targets??[]
 const points=(Array.isArray(targets)?targets:[targets]).filter(Boolean)
 const validPoints=points.length>0&&points.every(p=>Number.isFinite(Number(p.x))&&Number.isFinite(Number(p.y))&&p.x>=0&&p.x<=100&&p.y>=0&&p.y<=100)
 report.push({id:q.id,type:q.type,asset:source.slice(0,110),exists,validPoints,readyForHumanReview:exists&&validPoints})
}
console.log(JSON.stringify({total:report.length,assetsMissing:report.filter(x=>!x.exists).length,invalidTargets:report.filter(x=>!x.validPoints).length,report},null,2))
if(report.some(x=>!x.readyForHumanReview))process.exitCode=1
