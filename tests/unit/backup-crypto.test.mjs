import {test} from 'node:test'
import assert from 'node:assert/strict'
import {encryptBackup,decryptBackup} from '../../scripts/backup-crypto.mjs'
test('Encrypted backups round-trip binary data and reject tampering or a wrong key',()=>{
 const original=Buffer.from([0,255,1,2,3,0,128]),password='test-only-long-backup-passphrase'
 const encrypted=encryptBackup(original,password)
 assert.deepEqual(decryptBackup(encrypted,password),original)
 assert.throws(()=>decryptBackup(encrypted,'different-long-passphrase'))
 const tampered=Buffer.from(encrypted);tampered[tampered.length-1]^=1
 assert.throws(()=>decryptBackup(tampered,password))
 assert.throws(()=>encryptBackup(original,'short'))
})
