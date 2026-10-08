/**
 * One-time migration of locally downloaded course PDFs into private Supabase Storage.
 * Run from a trusted administrator machine, NEVER from the browser or CI logs.
 * Requires SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY in the environment.
 * Usage: node scripts/migrate-course-pdfs.mjs /path/to/pdfs [--apply]
 * Dry-run by default. Files are matched by their exact course_documents.file_name.
 * No source files are deleted.
 */
import { createClient } from '@supabase/supabase-js'
import { readFile, readdir } from 'node:fs/promises'
import { resolve, join } from 'node:path'
import { createHash } from 'node:crypto'

const [folderArg, flag] = process.argv.slice(2)
if (!folderArg || (flag && flag !== '--apply')) {
  console.error('Usage: node scripts/migrate-course-pdfs.mjs <pdf-folder> [--apply]')
  process.exit(2)
}
const apply = flag === '--apply'
const url = process.env.SUPABASE_URL
const key = process.env.SUPABASE_SERVICE_ROLE_KEY
if (!url || !key) throw new Error('SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY required')
const client = createClient(url, key, { auth: { persistSession: false, autoRefreshToken: false } })
const folder = resolve(folderArg)
const names = new Set(await readdir(folder))
let offset = 0, scanned = 0, migrated = 0, missing = 0
while (true) {
  const { data: docs, error } = await client.from('course_documents')
    .select('id,title,file_name,storage_path,mime_type')
    .order('id').range(offset, offset + 99)
  if (error) throw error
  if (!docs?.length) break
  for (const doc of docs) {
    scanned++
    if (!doc.file_name || !names.has(doc.file_name)) {
      missing++
      console.log('MISSING', doc.id, doc.file_name)
      continue
    }
    const bytes = await readFile(join(folder, doc.file_name))
    if (bytes.subarray(0, 5).toString() !== '%PDF-') {
      console.log('SKIP_NOT_PDF', doc.id, doc.file_name)
      continue
    }
    const digest = createHash('sha256').update(bytes).digest('hex')
    const path = `courses/${doc.id}/${digest}.pdf`
    console.log(apply ? 'IMPORT' : 'DRY_RUN', doc.id, doc.title, path, bytes.length)
    if (!apply) continue
    const { error: uploadError } = await client.storage.from('documents').upload(path, bytes, {
      contentType: 'application/pdf', upsert: false
    })
    if (uploadError && !/already exists|duplicate/i.test(uploadError.message)) throw uploadError
    const { data: files, error: listError } = await client.storage.from('documents').list(`courses/${doc.id}`, { search: `${digest}.pdf` })
    if (listError || !files?.some(file => file.name === `${digest}.pdf`)) throw new Error(`Upload not verified: ${doc.id}`)
    const { data: updated, error: updateError } = await client.from('course_documents')
      .update({ storage_path: path, mime_type: 'application/pdf', file_size: bytes.length })
      .eq('id', doc.id).eq('storage_path', doc.storage_path).select('id')
    if (updateError || updated?.length !== 1) throw new Error(`Document link update failed: ${doc.id}`)
    migrated++
  }
  offset += docs.length
  if (docs.length < 100) break
}
console.log(JSON.stringify({ scanned, missing, migrated, mode: apply ? 'apply' : 'dry-run' }))
