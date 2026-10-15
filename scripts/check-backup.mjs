// Offline integrity exercise only: does not restore anything to production.
import {readFile} from 'node:fs/promises'
import path from 'node:path'
import {createHash} from 'node:crypto'
import {decryptBackup} from './backup-crypto.mjs'
const [source]=process.argv.slice(2),password=process.env.LERYKO_BACKUP_PASSPHRASE
if(!source||!password)throw new Error('Provide a backup folder and its passphrase securely')
const manifest=JSON.parse(decryptBackup(await readFile(path.join(source,'manifest.leryko-backup')),password))
if(!manifest.complete)throw new Error('Backup is incomplete')
for(const item of manifest.objects){
 if(!/^[a-f0-9]{64}\.leryko-backup$/.test(item.file))throw new Error('Unsafe manifest path')
 const bytes=decryptBackup(await readFile(path.join(source,item.file)),password)
 if(bytes.length!==item.bytes||createHash('sha256').update(bytes).digest('hex')!==item.sha256)throw new Error('Backup integrity mismatch')
}
console.log(`Offline decryption and integrity verified for ${manifest.objects.length} objects. Database and application restore remain separate acceptance checks.`)
