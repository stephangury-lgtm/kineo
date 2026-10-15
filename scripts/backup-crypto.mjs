import {randomBytes,scryptSync,createCipheriv,createDecipheriv} from 'node:crypto'
const magic=Buffer.from('LERYKO-BACKUP-1\n')
export function encryptBackup(bytes,passphrase){
 if(typeof passphrase!=='string'||passphrase.length<20)throw new Error('Backup passphrase must contain at least 20 characters')
 const salt=randomBytes(16),iv=randomBytes(12)
 const key=scryptSync(passphrase,salt,32,{N:32768,r:8,p:1,maxmem:64*1024*1024})
 const cipher=createCipheriv('aes-256-gcm',key,iv)
 cipher.setAAD(magic)
 const ciphertext=Buffer.concat([cipher.update(bytes),cipher.final()])
 key.fill(0)
 return Buffer.concat([magic,salt,iv,cipher.getAuthTag(),ciphertext])
}
export function decryptBackup(bytes,passphrase){
 if(!bytes.subarray(0,magic.length).equals(magic))throw new Error('Invalid backup format')
 const n=magic.length,salt=bytes.subarray(n,n+16),iv=bytes.subarray(n+16,n+28),tag=bytes.subarray(n+28,n+44)
 const key=scryptSync(passphrase,salt,32,{N:32768,r:8,p:1,maxmem:64*1024*1024})
 const cipher=createDecipheriv('aes-256-gcm',key,iv)
 cipher.setAAD(magic);cipher.setAuthTag(tag)
 try{return Buffer.concat([cipher.update(bytes.subarray(n+44)),cipher.final()])}finally{key.fill(0)}
}
