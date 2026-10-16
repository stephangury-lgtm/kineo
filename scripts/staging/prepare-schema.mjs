// Generates a staging-only baseline from catalog metadata, never application rows.
import {readFile,writeFile} from 'node:fs/promises'
const catalog=JSON.parse(await readFile(new URL('./catalog.json',import.meta.url),'utf8'))
const source='kimtiyuytikyseuzmjbv',target='cyzdivbdgpvhwpmikeqh'
if(catalog.source_project!==source||catalog.target_project!==target)throw Error('Unexpected project pair')
const schemas=['public','private','app_security','kineo_internal','retention']
const ident=s=>'"'+s.replaceAll('"','""')+'"'
const literal=s=>"'"+s.replaceAll("'","''")+"'"
const qualified=(schema,name)=>`${ident(schema)}.${ident(name)}`
const role=s=>s==='PUBLIC'?'PUBLIC':ident(s)
const sql=[`-- STAGING ONLY. Target: ${target}. No production rows, secrets, jobs or extensions copied.
-- External mail/worker invocation routines are disabled explicitly below.
SET search_path = public, extensions;
SET check_function_bodies = false;
CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA extensions;`]
for(const schema of schemas){
 sql.push(`CREATE SCHEMA IF NOT EXISTS ${ident(schema)};`)
 sql.push(`REVOKE ALL ON SCHEMA ${ident(schema)} FROM PUBLIC, anon, authenticated, service_role;`)
 sql.push(`ALTER DEFAULT PRIVILEGES IN SCHEMA ${ident(schema)} REVOKE ALL ON TABLES FROM PUBLIC, anon, authenticated, service_role;`)
 sql.push(`ALTER DEFAULT PRIVILEGES IN SCHEMA ${ident(schema)} REVOKE ALL ON FUNCTIONS FROM PUBLIC, anon, authenticated, service_role;`)
}
for(const t of catalog.tables){
 if(!schemas.includes(t.schema))throw Error('Unexpected table schema')
 const columns=t.columns.map(c=>{
  if(c.generated)throw Error('Generated column needs review')
  return `${ident(c.name)} ${c.type}${c.identity?` GENERATED ${c.identity==='a'?'ALWAYS':'BY DEFAULT'} AS IDENTITY`:c.default?` DEFAULT ${c.default}`:''}${c.not_null?' NOT NULL':''}`
 })
 sql.push(`CREATE TABLE ${qualified(t.schema,t.name)} (\n ${columns.join(',\n ')}\n);`)
 if(t.rls)sql.push(`ALTER TABLE ${qualified(t.schema,t.name)} ENABLE ROW LEVEL SECURITY;`)
 if(t.force_rls)sql.push(`ALTER TABLE ${qualified(t.schema,t.name)} FORCE ROW LEVEL SECURITY;`)
}
// Unique/primary keys must exist before the foreign keys that reference them.
for(const foreign of [false,true])for(const c of catalog.constraints.filter(c=>(c.type==='f')===foreign)){
 sql.push(`ALTER TABLE ${qualified(c.schema,c.table)} ADD CONSTRAINT ${ident(c.name)} ${c.definition};`)
}
for(const i of catalog.indexes)sql.push(i.definition+';')
for(const f of catalog.routines){
 let definition=f.definition.replaceAll(source,target)
 if(['retention.invoke_worker','public.queue_inactivity_reminders_v1'].includes(`${f.schema}.${f.name}`)){
  definition=`CREATE OR REPLACE FUNCTION ${qualified(f.schema,f.name)}(${f.identity}) RETURNS ${f.name==='invoke_worker'?'bigint':'jsonb'} LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $staging$ BEGIN RAISE EXCEPTION 'External delivery disabled in staging'; END; $staging$;`
 }
 sql.push(definition+';')
}
const pending=[...catalog.views],done=new Set()
while(pending.length){
 const index=pending.findIndex(v=>!catalog.views.some(other=>other!==v&&v.definition.includes(other.name)&&!done.has(other.name)))
 if(index<0)throw Error('Unresolved view dependencies')
 const [v]=pending.splice(index,1)
 sql.push(`CREATE VIEW ${qualified(v.schema,v.name)}${v.options?.length?' WITH ('+v.options.join(', ')+')':''} AS ${v.definition.replace(/;\s*$/,'')};`)
 done.add(v.name)
}
for(const t of catalog.triggers)sql.push(t.definition+';')
for(const p of catalog.policies){
 sql.push(`CREATE POLICY ${ident(p.policyname)} ON ${qualified(p.schemaname,p.tablename)} AS ${p.permissive} FOR ${p.cmd} TO ${p.roles.map(role).join(', ')}${p.qual?' USING ('+p.qual+')':''}${p.with_check?' WITH CHECK ('+p.with_check+')':''};`)
}
// Fresh project defaults must not broaden the production access contract.
for(const schema of schemas){
 sql.push(`REVOKE ALL ON ALL TABLES IN SCHEMA ${ident(schema)} FROM PUBLIC, anon, authenticated, service_role;`)
 sql.push(`REVOKE ALL ON ALL FUNCTIONS IN SCHEMA ${ident(schema)} FROM PUBLIC, anon, authenticated, service_role;`)
}
for(const g of catalog.schema_grants)sql.push(`GRANT USAGE ON SCHEMA ${ident(g.schema)} TO ${role(g.grantee)};`)
// Do not reproduce legacy broad grants: anonymous access is never needed here.
// Authenticated writes require a matching permissive policy; invoker views may be read.
const tableGrants=catalog.grants.filter(g=>{
 if(['anon','PUBLIC'].includes(g.grantee))return false
 if(g.grantee==='service_role')return ['SELECT','INSERT','UPDATE','DELETE'].includes(g.privilege_type)
 return catalog.policies.some(p=>p.schemaname===g.table_schema&&p.tablename===g.table_name&&p.permissive==='PERMISSIVE'&&(p.cmd===g.privilege_type||p.cmd==='ALL')&&(p.roles.includes('authenticated')||p.roles.includes('public')))
  ||g.privilege_type==='SELECT'&&catalog.views.some(v=>v.schema===g.table_schema&&v.name===g.table_name&&v.options?.includes('security_invoker=true'))
})
for(const g of tableGrants)sql.push(`GRANT ${g.privilege_type} ON TABLE ${qualified(g.table_schema,g.table_name)} TO ${role(g.grantee)};`)
for(const g of catalog.column_grants)sql.push(`GRANT ${g.privilege_type} (${ident(g.column_name)}) ON TABLE ${qualified(g.table_schema,g.table_name)} TO ${role(g.grantee)};`)
for(const g of catalog.function_grants.filter(g=>!['anon','PUBLIC'].includes(g.grantee)))sql.push(`GRANT ${g.privilege} ON FUNCTION ${qualified(g.schema,g.name)}(${g.identity}) TO ${role(g.grantee)};`)
for(const b of catalog.storage_buckets){
 sql.push(`INSERT INTO storage.buckets(id,name,public,file_size_limit,allowed_mime_types) VALUES (${literal(b.id)},${literal(b.name)},${b.public},${b.file_size_limit},ARRAY[${b.allowed_mime_types.map(literal).join(',')}]::text[]);`)
}
const result=sql.join('\n')+'\n'
if(result.includes(source))throw Error('Production reference remains')
if(/cron\.schedule\s*\(|sb_secret_|Bearer eyJ/.test(result))throw Error('Unexpected active integration or credential')
await writeFile(new URL('./baseline.sql',import.meta.url),result)
console.log(`Staging baseline generated: ${catalog.tables.length} tables, ${catalog.views.length} views, ${catalog.routines.length} routines; no deployment performed.`)
