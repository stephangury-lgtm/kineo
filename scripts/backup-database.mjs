// Requires PostgreSQL 17+ pg_dump in PATH and PGHOST/PGPORT/PGUSER/
// PGDATABASE/PGPASSFILE from a secure environment. No passwords in arguments.
import {spawnSync} from 'node:child_process'
import {writeFile,mkdir} from 'node:fs/promises'
import path from 'node:path'
import {createHash} from 'node:crypto'
import {encryptBackup,decryptBackup} from './backup-crypto.mjs'

const output=process.env.LERYKO_BACKUP_DIRECTORY
const passphrase=process.env.LERYKO_BACKUP_PASSPHRASE
if(!output||!passphrase||passphrase.length<20)throw new Error('Set a private backup directory and a passphrase of at least 20 characters')
for(const key of ['PGHOST','PGUSER','PGDATABASE','PGPASSFILE'])if(!process.env[key])throw new Error(`Missing ${key}`)
if(process.env.PGSSLMODE!=='verify-full')throw new Error('PGSSLMODE=verify-full and a trusted root certificate are required')
{
 const result=spawnSync('pg_dump',['--format=custom','--no-owner','--no-privileges'],{env:process.env,stdio:'pipe',maxBuffer:128*1024*1024})
 if(result.error||result.status!==0)throw new Error('pg_dump failed; verify the PostgreSQL client version, connection and certificate privately')
 const bytes=result.stdout
 const encrypted=encryptBackup(bytes,passphrase)
 if(!decryptBackup(encrypted,passphrase).equals(bytes))throw new Error('Backup encryption verification failed')
 await mkdir(output,{recursive:true,mode:0o700})
 const target=path.join(output,`database-${new Date().toISOString().replace(/[:.]/g,'-')}.leryko-backup`)
 await writeFile(target,encrypted,{mode:0o600,flag:'wx'})
 await writeFile(target+'.sha256',createHash('sha256').update(encrypted).digest('hex')+'\n',{mode:0o600,flag:'wx'})
 console.log('Encrypted database export verified and saved. Storage binaries require a separate backup; a restore exercise is still required.')
}
