// Static gate only: successful execution is NOT proof of SQL installation or RLS behavior.
import {readFile,writeFile} from 'node:fs/promises'
import {createHash} from 'node:crypto'
import assert from 'node:assert/strict'
const sql=await readFile(new URL('./baseline.sql',import.meta.url),'utf8')
assert(sql.startsWith('-- STAGING ONLY. Target: cyzdivbdgpvhwpmikeqh.'))
assert(!sql.includes('kimtiyuytikyseuzmjbv'),'Production reference')
assert(!/^GRANT [^;]* ON (?:TABLE|FUNCTION|SEQUENCE) [^;]* TO (?:PUBLIC|"?anon"?)\s*;/im.test(sql),'Anonymous application grant')
assert(!/cron\.schedule\s*\(|CREATE EXTENSION[^;]*(?:pg_net|pg_cron)/i.test(sql),'Active scheduling or HTTP extension')
assert(!/sb_secret_|Bearer eyJ|re_[A-Za-z0-9]{20,}/.test(sql),'Potential credential')
const writable=new Set(['user_notes:INSERT','user_notes:UPDATE','user_notes:DELETE','friendships:INSERT','challenges:INSERT','notifications:UPDATE','profile_programs:INSERT','profile_programs:UPDATE','favorites:INSERT','favorites:UPDATE','favorites:DELETE','weekly_friend_email_preferences:INSERT','weekly_friend_email_preferences:UPDATE'])
const writes=[...sql.matchAll(/^GRANT (INSERT|UPDATE|DELETE|TRUNCATE|TRIGGER|REFERENCES) ON TABLE "([^"]+)"\."([^"]+)" TO "authenticated";$/gm)]
assert.equal(writes.length,writable.size)
for(const [,privilege,schema,table] of writes)assert(schema==='public'&&writable.has(`${table}:${privilege}`),'Unexpected authenticated write grant')
for(const name of ['"retention"."invoke_worker"','"public"."queue_inactivity_reminders_v1"']){
 const definition=sql.slice(sql.indexOf('CREATE OR REPLACE FUNCTION '+name))
 assert(definition.startsWith('CREATE OR REPLACE FUNCTION '+name)&&definition.slice(0,400).includes("RAISE EXCEPTION 'External delivery disabled in staging'"),'External delivery routine not disabled')
}
const report={target_project:'cyzdivbdgpvhwpmikeqh',sha256:createHash('sha256').update(sql).digest('hex'),tables:(sql.match(/^CREATE TABLE /gm)||[]).length,views:(sql.match(/^CREATE VIEW /gm)||[]).length,functions:(sql.match(/^CREATE OR REPLACE FUNCTION /gm)||[]).length,policies:(sql.match(/^CREATE POLICY /gm)||[]).length,authenticated_table_write_grants:writes.length,anonymous_application_grants:0,static_checks:'passed',sql_execution:'not_verified',connected_tests:'not_run',note:'Checksum identifies this file; it is not an authenticity signature.'}
await writeFile(new URL('./validation.json',import.meta.url),JSON.stringify(report,null,2)+'\n')
console.log(JSON.stringify(report,null,2))
